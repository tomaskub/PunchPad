//
//  PayManager.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import Foundation
import Combine

final class PayManager: ObservableObject {
    ///Data manager used to retrieve existing data
    private var dataManager: DataManager
    ///Setting store used to retrieve user settings
    private var settingsStore: SettingsStore
    ///Calendar service used to perform date calculations and comparisions
    private var calendar: Calendar
    ///Temporary overtime pay coeficcient implementation
    private var overtimePayCoef: Double = 1.5
    ///Set of all combine subscribers
    private var subscriptions = Set<AnyCancellable>()
    ///Current period driving gross salary data
    @Published private var currentPeriod: Period
    ///Gross salary data generated for a given period of time
    @Published private(set) var grossDataForPeriod: GrossSalary
    
    init(dataManager: DataManager, settingsStore: SettingsStore, currentPeriod: Period = (Date(), Date()), calendar: Calendar) {
        self.settingsStore = settingsStore
        self.dataManager = dataManager
        self.currentPeriod = currentPeriod
        self.calendar = calendar
        self.grossDataForPeriod = .init()
        setStoreSubscribers()
        setCurrentPeriodSubscriber()
    }
    
    ///Update current period driving published gross salary data
    func updatePeriod(with period: Period) {
        currentPeriod = period
    }
    
    /// Set subscribers to settingStore and dataManager changes
    private func setStoreSubscribers() {
        settingsStore.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &subscriptions)
        
        dataManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &subscriptions)
    }
    
    /// Set subscriber responsible for updating gross data for period on current period change
    private func setCurrentPeriodSubscriber() {
        $currentPeriod
            .removeDuplicates { lhs, rhs in
                return lhs.0 == rhs.0 && lhs.1 == rhs.1
            }.sink { [weak self] period in
                guard let self else { return }
                self.grossDataForPeriod = self.generateGrossDataForPeriod(period)
            }.store(in: &subscriptions)
    }
}

//MARK: GROSS PAY DISPLAY DATA GENERATING FUNCTIONS
private extension PayManager {
    /// Generate salary data based on given period
    /// - Parameter period: period for which salary data should be generated
    /// - Returns: generated gross salary data
    func generateGrossDataForPeriod(_ period: Period) -> GrossSalary {
        let entryData = dataManager.fetch(for: period)
        let averageWorktime: Int? = calculateAverage(from: entryData, keypath: \.workTimeInSeconds)
        let averageOvertime: Int? = calculateAverage(from: entryData, keypath: \.overTimeInSeconds)
        let processedEntries = processEntryData(in: period, from: entryData, averageWorktime: averageWorktime, averageOvertime: averageOvertime, calendar: calendar, store: settingsStore)
        
        let payUpToDate = entryData?.map { entry in
            calculateGrossPayFor(entry: entry, overtimePayCoef: 1.5, using: calendar)
        }.reduce(0, +)
        
        let predictedPay: Double? = {
            if period.0 > Date() { return nil }
            if entryData?.count != processedEntries.count || entryData?.count == 0 {
                return processedEntries.map { entry in
                    calculateGrossPayFor(entry: entry, overtimePayCoef: 1.5, using: calendar)
                }.reduce(0, +)
            } else {
                return nil
            }
        }()
        
        return .init(period: period,
                     payPerHour: calculateAverageGrossPayPerHour(from: processedEntries, using: calendar),
                     payUpToDate: payUpToDate ?? 0,
                     payPrediced: predictedPay,
                     numberOfWorkingDays: processedEntries.count)
    }
    
    /// Process avaliable entry data for the given period by adding empty entries before today and standard entries in future
    /// - Parameters:
    ///   - period: start and finish date touple
    ///   - entryData: existing retrieved entry data
    ///   - averageWorktime: average worktime to use for entries in the future
    ///   - averageOvertime: average overtime to use for entries in the future
    ///   - calendar: calendar used for comparisions and date generation
    ///   - store: store with default values
    /// - Returns: an array with existing entries and predicted future entries
    func processEntryData(in period: Period, from entryData: [Entry]?, averageWorktime: Int?, averageOvertime: Int?, calendar: Calendar, store: SettingsStore) -> [Entry] {
        return getWorkDaysInPeriod(using: calendar, in: period).map { date in
            if let retrievedEntry = entryData?.first(where: { calendar.isDate($0.startDate, inSameDayAs: date) }) {
                return retrievedEntry
            } else {
                let shouldAddEmptyTime = date < calendar.startOfDay(for: Date())
                return Entry(startDate: date,
                          finishDate: date,
                          workTimeInSec: shouldAddEmptyTime ? 0 : (averageWorktime ?? settingsStore.workTimeInSeconds),
                          overTimeInSec: shouldAddEmptyTime ? 0 : (averageOvertime ?? 0),
                          maximumOvertimeAllowedInSeconds: store.maximumOvertimeAllowedInSeconds,
                          standardWorktimeInSeconds: store.workTimeInSeconds,
                          grossPayPerMonth: store.grossPayPerMonth,
                          calculatedNetPay: nil
                         )
            }
        }
    }
}

//MARK: GROSS PAY CALCULATION
private extension PayManager {
    /// Calculate gross pay for given entry
    /// - Parameters:
    ///  - entry: entry for which the gross pay is calculated
    ///  - overtimePayCoef: overtime adjustment coefficient - standard 150% is 1.5
    /// - Returns: gross pay amount
    ///
    /// Function returns gross pay for given entry based on the time work, overtime worked, and gross pay per month set for the entry. Included overtime pay coefficient of 1.5 extra for overtime.
    func calculateGrossPayFor(entry: Entry, overtimePayCoef: Double, using calendar: Calendar) -> Double {
        let payPerHour = calculateGrossPayPerHour(for: entry, using: calendar)
        return calculateGrossPay(worktime: Double(entry.workTimeInSeconds),
                                 overtime: Double(entry.overTimeInSeconds),
                                 grossPayPerHour: payPerHour,
                                 overtimePayCoef: overtimePayCoef)
    }
    
    /// Calculate gross pay based on the input parameters
    /// - Parameters:
    ///   - worktime: standard work in seconds
    ///   - overtime: overtime in seconds
    ///   - grossPayPerHour: gross pay  per hour
    ///   - overtimePayCoef: overtime adjustment coefficient
    /// - Returns: gross pay
    func calculateGrossPay(worktime: Double, overtime: Double, grossPayPerHour: Double, overtimePayCoef: Double) -> Double {
        let worktimeHours = worktime / 3600
        let overtimeHours = overtime / 3600
        return grossPayPerHour * (worktimeHours + overtimePayCoef * overtimeHours)
    }
}

//MARK: AVERAGE GROSS PAY PER HOUR
private extension PayManager {
    /// Calculate average gross pay per hour based on gross monthly pay in entry
    /// - Parameter entries: an  array of entries
    /// - Returns: Average of gross pay per hour in entries
    func calculateAverageGrossPayPerHour(from entries: [Entry], using calendar: Calendar) -> Double {
        let payPerHourInEntries = entries.map { entry in
            calculateGrossPayPerHour(for: entry, using: calendar)
        }
        let sum = payPerHourInEntries.reduce(0, +)
        return sum / Double(payPerHourInEntries.count)
    }
    
    /// Calculate average of an Int property based on entry array
    /// - Parameters:
    ///   - input: optional entry array
    ///   - keypath: property keypath
    /// - Returns: average of the values for keypath propery in given array of entries, or nil if input is nil
    func calculateAverage(from input: [Entry]?, keypath: KeyPath<Entry, Int>) -> Int? {
        if let input, !input.isEmpty {
            return input.map { $0[keyPath: keypath] }.reduce(0, +) / input.count
        }
        return nil
    }
}

//MARK: GROSS PAY PER HOUR FUNCTIONS
private extension PayManager {
    /// Calculate gross pay per hour for given entry, based on data in entry
    /// - Parameter entry: entry for which to perform calculation
    /// - Returns: gross pay per hour
    ///
    /// Calculate gross pay per hour based on the provided entry, The gross pay per month stored in entry is used, with the number of working days in month retrived based on entry start date.
    func calculateGrossPayPerHour(for entry: Entry, using calendar: Calendar) -> Double {
        let numberOfWorkingHoursInDay = Double(entry.standardWorktimeInSeconds) / 3600
        let numberOfWorkingHours = Double(getNumberOfWorkingDays(using: calendar, inMonthOfDate: entry.startDate)) * numberOfWorkingHoursInDay
        return Double(entry.grossPayPerMonth) / numberOfWorkingHours
    }
}

//MARK: CALENDAR FUNCTIONS
private extension PayManager {
    /// Return an array containing start of the day dates of working days in input period
    /// - Parameters:
    ///   - calendar: calendar used for calculation
    ///   - period: date period (touple of start and finish dates)
    /// - Returns: an array of dates in period
    func getWorkDaysInPeriod(using calendar: Calendar, in period: Period) -> [Date] {
        guard let numberOfDays = calendar.dateComponents([.day], from: period.0, to: period.1).day,
              numberOfDays > 0 else { return [] }
        let result: [Date] = [Int](0..<numberOfDays).compactMap { i in
            calendar.date(byAdding: .day, value: i, to: period.0)
        }.filter { date in
            !calendar.isDateInWeekend(date)
        }
        return result
    }
    
    /// Get the number of working days in month containing given date
    /// - Parameters:
    ///   - calendar: calendar used for calculation
    ///   - date: date contained in month
    /// - Returns: number of working days in month
    ///
    /// Function checks for weekend days only. Holidays are counting as working days, as they are normally paid as standard length working days. Default calendar used is the current instance of calendar, while default date is now.
    func getNumberOfWorkingDays(using calendar: Calendar, inMonthOfDate date: Date = Date()) -> Int {
        let components = calendar.dateComponents([.month, .year], from: date)
        let startOfTheMonth = calendar.date(from: components)!
        let numberOfDays = calendar.range(of: .day, in: .month, for: startOfTheMonth)!.count
        let daysInMonth = Array(0..<numberOfDays).map { i in
            calendar.date(byAdding: .day, value: i, to: startOfTheMonth)!
        }
        let workDays = daysInMonth.filter({ !calendar.isDateInWeekend($0) })
        return workDays.count
    }
}

//MARK: - NET PAY FUNCTIONS - FOR NOW UNUSED
extension PayManager {
    ///Calculate net pay based on gross pay given, using standard polish taxation for work contract
    /// - Parameters:
    /// - gross - the gross pay to be taxed as a Double
    /// - Returns: net pay calculated
    func calculateNetPay(gross: Double) -> Double {
        let skladkaEmerytalna = 0.0976 * gross
        let skladkaRentowa = 0.015 * gross
        let skladkaChorobowa = 0.0245 * gross
        let skladkaWypoczynkowa = 0.0132 * gross
        let sumOfSkladka = skladkaEmerytalna + skladkaRentowa + skladkaChorobowa + skladkaWypoczynkowa
        let skladkaZdrowotna = (gross - sumOfSkladka) * 0.09
        var podatekDochodowy = 0.12 * (gross - sumOfSkladka - 300)
        if podatekDochodowy < 0 {
            podatekDochodowy = 0
        }
        let netPay = gross - podatekDochodowy - skladkaZdrowotna - sumOfSkladka
        
        return netPay
    }
}



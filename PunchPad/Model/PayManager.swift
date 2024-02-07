//
//  PayManager.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import Foundation
import Combine

class PayManager: ObservableObject {
    private var dataManager: DataManager
    private var settingsStore: SettingsStore
    private var subscriptions = Set<AnyCancellable>()
    @Published private var currentPeriod: Period
    @Published var grossDataForPeriod: GrossSalary
    
    init(dataManager: DataManager, settingsStore: SettingsStore, currentPeriod: Period = (Date(), Date())) {
        self.settingsStore = settingsStore
        self.dataManager = dataManager
        // new property init
        self.currentPeriod = currentPeriod
        self.grossDataForPeriod = .init()
        setSubscribers()
    }
    ///Update current period driving gross data
    func updatePeriod(with period: Period) {
        currentPeriod = period
    }
    // subscribers for changing data in settings store and data manager - might be not needed
    private func setSubscribers() {
        settingsStore.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &subscriptions)
        
        dataManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &subscriptions)
        
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
extension PayManager {
    private func generateGrossDataForPeriod(_ period: Period) -> GrossSalary {
        let entryData = dataManager.fetch(for: period)
        let averageWorktime: Int? = calculateAverage(from: entryData, keypath: \.workTimeInSeconds)
        let averageOvertime: Int? = calculateAverage(from: entryData, keypath: \.overTimeInSeconds)
        let processedEntries = processEntryData(in: period, from: entryData, averageWorktime: averageWorktime, averageOvertime: averageOvertime, calendar: .current, store: settingsStore)
        
        let payUpToDate = entryData?.map { entry in
            calculateGrossPayFor(entry: entry, overtimePayCoef: 1.5)
        }.reduce(0, +)
        
        let predictedPay: Double? = {
            if period.0 > Date() { return nil }
            if entryData?.count != processedEntries.count || entryData?.count == 0 {
                return processedEntries.map { entry in
                    calculateGrossPayFor(entry: entry, overtimePayCoef: 1.5)
                }.reduce(0, +)
            } else {
                return nil
            }
        }()
        
        return .init(period: period,
                     payPerHour: calculateAverageGrossPayPerHour(from: processedEntries),
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
    private func processEntryData(in period: Period, from entryData: [Entry]?, averageWorktime: Int?, averageOvertime: Int?, calendar: Calendar, store: SettingsStore) -> [Entry] {
        return getWorkDaysInPeriod(in: period).map { date in
            if let retrievedEntry = entryData?.first(where: { calendar.isDate($0.startDate, inSameDayAs: date) }) {
                return retrievedEntry
            } else {
                let shouldAddEmptyTime = date < Calendar.current.startOfDay(for: Date())
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
extension PayManager {
    /// Calculate gross pay for given entry
    /// - Parameters:
    ///  - entry: entry for which the gross pay is calculated
    ///  - overtimePayCoef: overtime adjustment coefficient - standard 150% is 1.5
    /// - Returns: gross pay amount
    ///
    /// Function returns gross pay for given entry based on the time work, overtime worked, and gross pay per month set for the entry. Included overtime pay coefficient of 1.5 extra for overtime.
    private func calculateGrossPayFor(entry: Entry, overtimePayCoef: Double) -> Double {
        let payPerHour = calculateGrossPayPerHour(for: entry)
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
    private func calculateGrossPay(worktime: Double, overtime: Double, grossPayPerHour: Double, overtimePayCoef: Double) -> Double {
        let worktimeHours = worktime / 3600
        let overtimeHours = overtime / 3600
        return grossPayPerHour * (worktimeHours + overtimePayCoef * overtimeHours)
    }
}

//MARK: AVERAGE GROSS PAY PER HOUR
extension PayManager {
    /// Calculate average gross pay per hour based on gross monthly pay in entry
    /// - Parameter entries: an  array of entries
    /// - Returns: Average of gross pay per hour in entries
    private func calculateAverageGrossPayPerHour(from entries: [Entry]) -> Double {
        let payPerHourInEntries = entries.map { entry in
            calculateGrossPayPerHour(for: entry)
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
extension PayManager {
    /// Calculate gross pay per hour for given entry, based on data in entry
    /// - Parameter entry: entry for which to perform calculation
    /// - Returns: gross pay per hour
    ///
    /// Calculate gross pay per hour based on the provided entry, The gross pay per month stored in entry is used, with the number of working days in month retrived based on entry start date.
    private func calculateGrossPayPerHour(for entry: Entry) -> Double {
        let numberOfWorkingHoursInDay = Double(entry.standardWorktimeInSeconds) / 3600
        let numberOfWorkingHours = Double(getNumberOfWorkingDays(inMonthOfDate: entry.startDate)) * numberOfWorkingHoursInDay
        return Double(entry.grossPayPerMonth) / numberOfWorkingHours
    }
}

//MARK: CALENDAR FUNCTIONS
extension PayManager {
    /// Return an array containing start of the day dates of working days in input period
    /// - Parameters:
    ///   - calendar: calendar used for calculation
    ///   - period: date period (touple of start and finish dates)
    /// - Returns: an array of dates in period
    private func getWorkDaysInPeriod(using calendar: Calendar = .current, in period: Period) -> [Date] {
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
    private func getNumberOfWorkingDays(using calendar: Calendar = .current, inMonthOfDate date: Date = Date()) -> Int {
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



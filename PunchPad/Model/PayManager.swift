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
        return period.1 > Date() ?
        generateDataForCurrrentPeriod(period, from: dataManager) :
        generateGrossDataForPastPeriod(period, from: dataManager)
    }
     
    private func generateDataForCurrrentPeriod(_ period: Period, from dataManager: DataManager) -> GrossSalary {
        
        guard let data = dataManager.fetch(for: period) else { return .init() }
        let numberOfWorkingDays = getNumberOfWorkingDays(in: period)
        let payUpToDate = data.map { calculateGrossPayFor(entry: $0, overtimePayCoef: 1.5) } .reduce(0, +)
        
        let payPerHour = {
            !data.isEmpty ? calculateAverageGrossPayPerHour(from: data) : calculateAverageGrossPayPerHour(forPeriod: period)
        }()
        
        let averageWorktime = data.map { Double($0.workTimeInSeconds) }.reduce(0, +) / Double(data.count)
        let averageOvertime = data.map { Double($0.overTimeInSeconds) }.reduce(0, +) / Double(data.count)
        
        var payPredicted: Double? = {
            let daysInPeriod: [Date] = getWorkDaysInPeriod(in: period)
            let addedDays = daysInPeriod
                .filter { date in
                    !data.contains(where: {
                        Calendar.current.isDate(date, inSameDayAs: $0.startDate)
                    })
                }
                .map { date in
                    calculateGrossPay(worktime: averageWorktime,
                                      overtime: averageOvertime,
                                      grossPayPerHour: payPerHour,
                                      overtimePayCoef: 1.5)
                }
            return addedDays.reduce(payUpToDate, +)
        }()
        return .init(period: period,
                     payPerHour: payPerHour,
                     payUpToDate: payUpToDate,
                     payPrediced: payPredicted,
                     numberOfWorkingDays: numberOfWorkingDays)
    }
    
    /// Generate gross salary data for past period based on saved data
    /// - Parameter period: period (touple of start and finish dates) representing the timeframe
    /// - Parameter dataManager: data manager instance containing the entries
    /// - Returns: GrossSalary object containing salary data
    private func generateGrossDataForPastPeriod(_ period: Period, from dataManager: DataManager) -> GrossSalary {
        guard let data = dataManager.fetch(for: period) else { return .init() }
        let payPerHour = {
            if !data.isEmpty {
                return calculateAverageGrossPayPerHour(from: data)
            } else {
                return calculateAverageGrossPayPerHour(forPeriod: period)
            }
        }()
        let numberOfWorkingDays = getNumberOfWorkingDays(in: period)
        let payUpToDate = data.map { calculateGrossPayFor(entry: $0, overtimePayCoef: 1.5) } .reduce(0, +)
        return .init(period: period,
                     payPerHour: payPerHour,
                     payUpToDate: payUpToDate,
                     payPrediced: nil,
                     numberOfWorkingDays: numberOfWorkingDays)
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
    
    ///  Calculate average gross pay per hour based on given period. Uses data from settings store.
    /// - Parameter period: period for which to calculate average
    /// - Returns: average of gross pay per hour for dates in period
    private func calculateAverageGrossPayPerHour(forPeriod period: Period) -> Double {
        guard let numberOfDays = Calendar.current.dateComponents([.day], from: period.0, to: period.1).day else { return 0 }
        var dates: [Date] = []
        for i in 0..<numberOfDays {
            if let date = Calendar.current.date(byAdding: .day, value: i, to: period.0) {
                dates.append(date)
            }
        }
        let grossPayForDates = dates.map { date in
            calculateGrossPayPerHour(forDate: date)
        }
        let sum = grossPayForDates.reduce(0, +)
        let average = sum / Double(dates.count)
        return average
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
    
    /// Calculate gross pay per hour in the month of date based on currently set gross pay per month
    /// - Returns: gross pay per hour
    private func calculateGrossPayPerHour(forDate date: Date) -> Double {
        let numberOfWorkingHoursInDay = Double(settingsStore.workTimeInSeconds) / 3600
        let numberOfWorkHours = Double(getNumberOfWorkingDays(inMonthOfDate: date)) * numberOfWorkingHoursInDay
        return Double(settingsStore.grossPayPerMonth) / numberOfWorkHours
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
    
    /// Get number of working days in given period
    /// - Parameters:
    ///   - calendar: calendar used for calculation
    ///   - period: date period (touple of start and finish dates)
    /// - Returns: number of working days in period
    private func getNumberOfWorkingDays(using calendar: Calendar = .current, in period: Period) -> Int {
        guard let numberOfDays = calendar.dateComponents([.day], from: period.0, to: period.1).day else { return 0}
        let daysInPeriod = Array(0..<numberOfDays).map { i in
            calendar.date(byAdding: .day, value: i, to: period.0)!
        }
        let workingDays = daysInPeriod.filter { !calendar.isDateInWeekend($0) }
        return workingDays.count
    }
    
    /// Get the number of working days passed since begining of the month
    /// - Parameters:
    ///   - calendar: calendar used for calculation
    ///   - date: date until which working days are counted
    /// - Returns: number of working days passed
    private func getNumberOfWorkingDaysPassed(using calendar: Calendar = .current, till date: Date = Date()) -> Int {
        // calculate how many working days already passed
        let components = calendar.dateComponents([.month, .year], from: date)
        let startOfTheMonth = calendar.date(from: components)!
        
        guard let numberOfDays = calendar.dateComponents([.day], from: startOfTheMonth, to: date).day else { return 0 }
        
        let daysPassed = Array(0..<numberOfDays).map { i in
            calendar.date(byAdding: .day, value: i, to: startOfTheMonth)!
        }
        let workDaysPassed = daysPassed.filter({ !calendar.isDateInWeekend($0) })
        
        return workDaysPassed.count
    }
}

//MARK: NET PAY FUNCTIONS - FOR NOW UNUSED
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



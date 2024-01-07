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
//MARK: CALENDAR FUNCTIONS
extension PayManager {
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

//MARK: GROSS PAY FUNCTIONS
extension PayManager {
    private func generateGrossDataForPeriod(_ period: Period) -> GrossSalary {
        return period.1 > Date() ?
        generateDataForPeriodEndingInFuture(period, from: dataManager) :
        generateGrossDataForPeriodInPast(period, from: dataManager)
    }
    
    private func generateDataForPeriodEndingInFuture(_ period: Period, from dataManager: DataManager) -> GrossSalary {
        guard let data = dataManager.fetch(for: period) else { return .init() }
        let numberOfWorkingDays = getNumberOfWorkingDays(in: period)
        let payPerHour = calculateAverageGrossPayPerHour(from: data)
        let payUpToDate = data.map { calculateGrossPayFor(entry: $0, overtimePayCoef: 1.5) } .reduce(0, +)
        
        let averageWorktime = data.map { Double($0.workTimeInSeconds) }.reduce(0, +) / Double(data.count)
        let averageOvertime = data.map { Double($0.overTimeInSeconds) }.reduce(0, +) / Double(data.count)
        var payPredicted: Double?
        
        if let lastEntry = data.last,
           let numberOfDaysInFuture = Calendar.current.dateComponents([.day], from: lastEntry.startDate, to: period.1).day {
            for i in 0..<numberOfDaysInFuture {
                if let currentDate = Calendar.current.date(byAdding: .day, value: i, to: lastEntry.startDate), 
                    !Calendar.current.isDateInWeekend(currentDate),
                   !data.contains(where: { Calendar.current.isDate($0.startDate, inSameDayAs: currentDate)
                   }){
                        let payForDate = calculateGrossPay(worktime: averageWorktime, overtime: averageOvertime, grossPayPerHour: payPerHour, overtimePayCoef: 1.5)
                        payPredicted = payForDate + (payPredicted ?? 0)
                }
            }
        }
        
        return .init(period: period,
                     payPerHour: payPerHour,
                     payUpToDate: payUpToDate,
                     payPrediced: payPredicted,
                     numberOfWorkingDays: numberOfWorkingDays)
    }
    
    /// generate gross salary data for past period based on saved data
    /// - Parameter period: period (touple of start and finish dates) representing the timeframe
    /// - Parameter dataManager: data manager instance containing the entries
    /// - Returns: GrossSalary object containing salary data
    private func generateGrossDataForPeriodInPast(_ period: Period, from dataManager: DataManager) -> GrossSalary {
        guard let data = dataManager.fetch(for: period) else { return .init() }
        let payPerHour = calculateAverageGrossPayPerHour(from: data)
        let numberOfWorkingDays = getNumberOfWorkingDays(in: period)
        let payUpToDate = data.map { calculateGrossPayFor(entry: $0, overtimePayCoef: 1.5) } .reduce(0, +)
        return .init(period: period,
                     payPerHour: payPerHour,
                     payUpToDate: payUpToDate,
                     payPrediced: nil,
                     numberOfWorkingDays: numberOfWorkingDays)
    }
    
    private func calculateAverageGrossPayPerHour(from entries: [Entry]) -> Double {
        let payPerHourInEntries = entries.map { entry in
            calculateGrossPayPerHour(for: entry)
        }
        let sum = payPerHourInEntries.reduce(0, +)
        return sum / Double(payPerHourInEntries.count)
    }

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

    /// Calculate gross pay per hour for given entry
    /// - Parameter entry: entry for which to perform calculation
    /// - Returns: gross pay per hour
    ///
    /// Calculate gross pay per hour based on the provided entry, The gross pay per month stored in entry is used, with the number of working days in month retrived based on entry start date.
    private func calculateGrossPayPerHour(for entry: Entry) -> Double {
        let numberOfWorkingHoursInDay = Double(entry.standardWorktimeInSeconds) / 3600
        let numberOfWorkingHours = Double(getNumberOfWorkingDays(inMonthOfDate: entry.startDate)) * numberOfWorkingHoursInDay
        return Double(entry.grossPayPerMonth) / numberOfWorkingHours
    }


    /// Calculate gross pay per hour in the current mont based on current set gross pay per month
    /// - Returns: gross pay per hour
    private func calculateGrossPayPerHour() -> Double {
        let numberOfWorkHours = Double(getNumberOfWorkingDays() * settingsStore.workTimeInSeconds) / 3600
        return Double(settingsStore.grossPayPerMonth) / numberOfWorkHours
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



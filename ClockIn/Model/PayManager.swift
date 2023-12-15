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
    private var grossPayPerMonth: Double
    private var subscriptions = Set<AnyCancellable>()
    var entriesThisMonth = [Entry]()
    //MARK: PUBLISHED PROPERTIES
    @Published var numberOfWorkingDays: Int = 20
    @Published var netPayToDate: Double  = 1.0
    @Published var netPayPredicted: Double = 1.0
    @Published var grossPayToDate: Double = 1
    @Published var grossPayPredicted: Double = 1
    @Published var netPayAvaliable: Bool
    @Published var grossPayPerHour: Double = 0
    
    init(dataManager: DataManager, settingsStore: SettingsStore) {
        self.settingsStore = settingsStore
        self.dataManager = dataManager
        self.netPayAvaliable = settingsStore.isCalculatingNetPay
        self.grossPayPerMonth = Double(settingsStore.grossPayPerMonth)
        setSubscribers()
    }
    
    private func setSubscribers() {
        settingsStore.$grossPayPerMonth
            .sink { [weak self] newGross in
            guard let self else { return }
            self.grossPayPerMonth = Double(newGross)
            self.updatePublishedValues()
        }.store(in: &subscriptions)
        
        settingsStore.$isCalculatingNetPay
            .receive(on: RunLoop.main)
            .sink { [weak self] newValue in
                self?.netPayAvaliable = newValue
            }.store(in: &subscriptions)
        
        dataManager.$entryThisMonth.sink { [weak self] array in
            guard let self else { return }
            self.entriesThisMonth = array
            self.updatePublishedValues()
        }.store(in: &subscriptions)
        
        dataManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &subscriptions)
    }
    
    /// Update all values published based on avaliable entriesThisMonth
    func updatePublishedValues() {
        // Get number of working days and calculate gross pay per hour
        self.numberOfWorkingDays = getNumberOfWorkingDays()
        self.grossPayPerHour = calculateGrossPayPerHour()
        // Calculate gross and net pay to date
        self.grossPayToDate = calculateGrossPay()
        self.netPayToDate = calculateNetPay(gross: grossPayToDate)
        // Calculate predicted gross and net pay for this month
        self.grossPayPredicted = calculatePredictedGrossPay()
        self.netPayPredicted = calculateNetPay(gross: grossPayPredicted)
    }
}
//MARK: CALENDAR FUNCTIONS
extension PayManager {
    func getNumberOfWorkingDays(inMonthOfDate date: Date = Date()) -> Int {
        let components = Calendar.current.dateComponents([.month, .year], from: date)
        let startOfTheMonth = Calendar.current.date(from: components)!
        let numberOfDays = Calendar.current.range(of: .day, in: .month, for: startOfTheMonth)!.count
        let daysInMonth = Array(0..<numberOfDays).map { i in
            Calendar.current.date(byAdding: .day, value: i, to: startOfTheMonth)!
        }
        let workDays = daysInMonth.filter({!Calendar.current.isDateInWeekend($0)})
        return workDays.count
    }
    
    func getNumberOfWorkingDaysPassed(till date: Date = Date()) -> Int {
        // calculate how many working days already passed
        let components = Calendar.current.dateComponents([.month, .year], from: date)
        let startOfTheMonth = Calendar.current.date(from: components)!
        
        guard let numberOfDays = Calendar.current.dateComponents([.day], from: startOfTheMonth, to: date).day else { return 0 }
        
        let daysPassed = Array(0..<numberOfDays).map { i in
            Calendar.current.date(byAdding: .day, value: i, to: startOfTheMonth)!
        }
        let workDaysPassed = daysPassed.filter({ !Calendar.current.isDateInWeekend($0) })
        
        return workDaysPassed.count
    }
}

//MARK: GROSS PAY FUNCTIONS
extension PayManager {
    func calculatePredictedGrossPay() -> Double {
        
        let numberOfWorkingDays = getNumberOfWorkingDays()
        let numberOfWorkingDaysPassed = getNumberOfWorkingDaysPassed()
        
        let grossToDate = calculateGrossPay()
        
        let multiplier: Double = Double(numberOfWorkingDays) / Double(numberOfWorkingDaysPassed)
        
        return grossToDate * multiplier
    }
    /// Calculate gross pay based on the saved entries in the time span given. If either of parameters is nil, gross pay for this month will be calculated
    func calculateGrossPay(from: Date? = nil, to: Date? = nil) -> Double {
        var sumAllTimeWorkedInSec = Int()
        guard let startDate = from, let finishDate = to else {
            
            for entry in entriesThisMonth {
                sumAllTimeWorkedInSec += entry.workTimeInSeconds + entry.overTimeInSeconds
            }
            // This is not very safe for large numbers with double?
            let sumAllTimeWorkedInHours = Double(sumAllTimeWorkedInSec) / 3600
            return sumAllTimeWorkedInHours * grossPayPerHour
        }
        
        if let entries = dataManager.fetch(from: startDate, to: finishDate) {
            
            for entry in entries {
                    sumAllTimeWorkedInSec += entry.workTimeInSeconds + entry.overTimeInSeconds
            }
            
            let sumAllTimeWorkedInHours = Double(sumAllTimeWorkedInSec) / 3600
            return sumAllTimeWorkedInHours * grossPayPerHour
        }
        
        return 0
    }
    
    func calculateGrossPayPerHour() -> Double {
        let numberOfWorkHours = Double(getNumberOfWorkingDays() * 8)
        return grossPayPerMonth / numberOfWorkHours
    }
}

//MARK: NET PAY FUNCTIONS
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

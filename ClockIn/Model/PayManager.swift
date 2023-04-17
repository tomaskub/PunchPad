//
//  PayManager.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import Foundation

class PayManager: ObservableObject {
    
    @Published private var dataManager: DataManager
    private let grossPayPerMonth: Double = 1090
    
    //MARK: PUBLISHED PROPERTIES
    @Published var numberOfWorkingDays: Int = 20
    @Published var netPayToDate: Double  = 1.0
    @Published var netPayPredicted: Double = 1.0
    @Published var grossPayToDate: Double = 1
    @Published var grossPayPredicted: Double = 1
    @Published var netPayAvaliable: Bool = true
    @Published var grossPayPerHour: Double = 68.13
    
    
    init(dataManager: DataManager = DataManager.shared) {
        
        self.dataManager = dataManager
        
        self.numberOfWorkingDays = getNumberOfWorkingDays()
        self.grossPayPerHour = calculateGrossPayPerHour()
        
        self.grossPayToDate = calculateGrossPay()
        self.netPayToDate = calculateNetPay(gross: grossPayToDate)
        
        self.grossPayPredicted = calculatePredictedGrossPay()
        self.netPayPredicted = calculateNetPay(gross: grossPayPredicted)
        
        
    }
    
    var entriesThisMonth: [Entry] {
        dataManager.entryThisMonth
    }
    
    ///Calculate net pay based on gross pay given, using standard polish taxation for work contract
    /// - Parameters:
    /// - gross - the gross pay to be taxed as a Double
    ///
    func calculateNetPay(gross: Double) -> Double {
        
        let skladkaEmerytalna = 0.0976 * gross
        let skladkaRentowa = 0.015 * gross
        let skladkaChorobowa = 0.0245 * gross
        let skladkaWypoczynkowa = 0.0132 * gross
        let sumOfSkladka = skladkaEmerytalna + skladkaRentowa + skladkaChorobowa + skladkaWypoczynkowa
        let skladkaZdrowotna = (gross - sumOfSkladka) * 0.09
        let podatekDochodowy = 0.12 * (gross - sumOfSkladka - 300) //- 300
        let netPay = gross - podatekDochodowy - skladkaZdrowotna - sumOfSkladka
        
        return netPay
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
    
    func calculatePredictedGrossPay() -> Double {
        
        let numberOfWorkingDays = getNumberOfWorkingDays()
        let numberOfWorkingDaysPassed = getNumberOfWorkingDaysPassed()
        
        let grossToDate = calculateGrossPay()
        
        let multiplier: Double = Double(numberOfWorkingDays) / Double(numberOfWorkingDaysPassed)
        
        return grossToDate * multiplier
    }
}

//
//  StatisticsViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import Foundation

class StatisticsViewModel: ObservableObject {
        
    @Published private var dataManager: DataManager
    private var maximumOvertimeInSeconds: Int
    private var workTimeInSeconds: Int
    
    @Published var netPayAvaliable: Bool = false
    
    init(dataManager: DataManager = DataManager.shared, overrideUserDefaults: Bool = false) {
        
        self.dataManager = dataManager
        
        if !overrideUserDefaults {
            self.maximumOvertimeInSeconds = UserDefaults.standard.integer(forKey: K.UserDefaultsKeys.maximumOverTimeAllowedInSeconds)
            self.workTimeInSeconds = UserDefaults.standard.integer(forKey: K.UserDefaultsKeys.workTimeInSeconds)
        } else {
            self.maximumOvertimeInSeconds = 5 * 3600
            self.workTimeInSeconds = 8 * 3600
        }
        
    }
    
    ///Entries for use with a chart - contains empy entries for days without the entry in this monts
    var entriesForChart: [Entry] {
        var dateComponents = Calendar.current.dateComponents([.month, .year], from: Date())
        let startDate = Calendar.current.date(from: dateComponents)!
        let range = Calendar.current.range(of: .day, in: .month, for: startDate)!
        let numberOfDays = range.count
        var placeholderArray: [Entry] = []
        for day in 1...numberOfDays {
            dateComponents.day = day
            let date = Calendar.current.date(from: dateComponents)!
            let placeholderEntry = Entry(
                startDate: date,
                finishDate: date,
                workTimeInSec: 0,
                overTimeInSec: 0
            )
            placeholderArray.append(placeholderEntry)
        }
        let result = placeholderArray.map { placeholder in
            let replacer = dataManager.entryArray.first { entry in
                Calendar.current.dateComponents([.day], from: entry.startDate) == Calendar.current.dateComponents([.day], from: placeholder.startDate)
            }
            return replacer ?? placeholder
        }
        return result
    }
    
    func calculateNetPay(gross: Double) -> Double {
        
        let skladkaEmerytalna = 0.0976 * gross
        let skladkaRentowa = 0.015 * gross
        let skladkaChorobowa = 0.0245 * gross
        let skladkaWypoczynkowa = 0.0132 * gross
        let sumOfSkladka = skladkaEmerytalna + skladkaRentowa + skladkaChorobowa + skladkaWypoczynkowa
        let skladkaZdrowotna = (gross - sumOfSkladka) * 0.09
        let podatekDochodowy = 0.12 * (gross - sumOfSkladka - 300) - 300
        let netPay = gross - podatekDochodowy - skladkaZdrowotna - sumOfSkladka
        
        return netPay
    }
}


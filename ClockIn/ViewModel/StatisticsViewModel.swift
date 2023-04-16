//
//  StatisticsViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import Foundation

class StatisticsViewModel: ObservableObject {
    
    //MARK: MODEL OBJECTS
    @Published private var dataManager: DataManager
    @Published private var payManager: PayManager
    
    //MARK: RETRIVED PROPERTIES
    private var maximumOvertimeInSeconds: Int
    private var workTimeInSeconds: Int
    
    
    //MARK: PUBLISHED VARIABLES
    var numberOfWorkingDays: Int {
        payManager.numberOfWorkingDays
    }
    var netPayToDate: Double {
        payManager.netPayToDate
    }
    var netPayPredicted: Double {
        payManager.netPayPredicted
    }
    var grossPayToDate: Double {
        payManager.grossPayToDate
    }
    var grossPayPredicted: Double {
        payManager.grossPayPredicted
    }
    var netPayAvaliable: Bool {
        payManager.netPayAvaliable
    }
    var grossPayPerHour: Double {
        payManager.grossPayPerHour
    }
    
    
    init(dataManager: DataManager = DataManager.shared, payManager: PayManager = PayManager(),overrideUserDefaults: Bool = false) {
        
        self.dataManager = dataManager
        self.payManager = payManager
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
}


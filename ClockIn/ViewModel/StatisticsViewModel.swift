//
//  StatisticsViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import Foundation
import Combine

enum ChartType {
    case time, startTime, finishTime
}

class StatisticsViewModel: ObservableObject {
    
    //MARK: MODEL OBJECTS
    @Published private var dataManager: DataManager
    @Published private var payManager: PayManager
    private var subscriptions = Set<AnyCancellable>()
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
    
    var salaryListDataNetPay: [(String, String)] {
        [ ("Net pay up to date:", String(format: "%.2f", netPayToDate)),
          ("Net pay predicted:", String(format: "%.2f", netPayPredicted))
        ]
    }
    
    var salaryListDataGrossPay: [(String, String)] {
        [("Gross pay per hour:", String(format: "%.2f", grossPayPerHour)),
         ("Gross pay up to date:", String(format: "%.2f", grossPayToDate)),
         ("Gross pay predicted:", String(format: "%.2f", grossPayPredicted)),
         ("Number of working days:", String(format: "%u", numberOfWorkingDays))
        ]
    }
    
    @Published var chartType: ChartType = .time
    
    init(dataManager: DataManager = DataManager.shared, payManager: PayManager = PayManager(), overrideUserDefaults: Bool = false) {
        
        self.dataManager = dataManager
        self.payManager = payManager
        if !overrideUserDefaults {
            self.maximumOvertimeInSeconds = UserDefaults.standard.integer(forKey: SettingsStore.SettingKey.maximumOvertimeAllowedInSeconds.rawValue)
            self.workTimeInSeconds = UserDefaults.standard.integer(forKey: SettingsStore.SettingKey.workTimeInSeconds.rawValue)
        } else {
            self.maximumOvertimeInSeconds = 5 * 3600
            self.workTimeInSeconds = 8 * 3600
        }
        
        dataManager.objectWillChange.sink(receiveValue: { [weak self] _ in
            self?.objectWillChange.send()
        }).store(in: &subscriptions)
        
        payManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &subscriptions)
        
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


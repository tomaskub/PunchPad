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
    @Published private var settingsStore: SettingsStore
    private var subscriptions = Set<AnyCancellable>()
    //MARK: RETRIVED PROPERTIES
    private var maximumOvertimeInSeconds: Int {
        settingsStore.maximumOvertimeAllowedInSeconds
    }
    private var workTimeInSeconds: Int {
        settingsStore.workTimeInSeconds
    }
    
    //TODO: WRAP IN MODEL STRUCT
    //MARK: PUBLISHED VARIABLES
    @Published var chartTimeRange: ChartTimeRange = .week
    
    var netPayAvaliable: Bool {
        payManager.netPayAvaliable
    }
    var salaryListDataNetPay: [(String, String)] {
        [ ("Net pay up to date:", String(format: "%.2f", payManager.netPayToDate) + " PLN"),
          ("Net pay predicted:", String(format: "%.2f", payManager.netPayPredicted) + " PLN")
        ]
    }
    
    var salaryListDataGrossPay: [(String, String)] {
        [("Gross pay per hour:", String(format: "%.2f", payManager.grossPayPerHour) + " PLN"),
         ("Gross pay up to date:", String(format: "%.2f", payManager.grossPayToDate) + " PLN"),
         ("Gross pay predicted:", String(format: "%.2f", payManager.grossPayPredicted) + " PLN"),
         ("Number of working days:", String(format: "%u", payManager.numberOfWorkingDays) + " DAYS")
        ]
    }
    var workedHoursInPeriod: Int {
        entriesForChart.map { entry in
            (entry.workTimeInSeconds + entry.overTimeInSeconds ) / 3600
        }.reduce(0, +)
    }
    var overtimeHoursInPeriod: Int {
        entriesForChart.map { entry in
            entry.overTimeInSeconds / 3600
        }.reduce(0, +)
    }
    
    init(dataManager: DataManager, payManager: PayManager, settingsStore: SettingsStore) {
        self.dataManager = dataManager
        self.payManager = payManager
        self.settingsStore = settingsStore
        
        dataManager.objectWillChange.sink(receiveValue: { [weak self] _ in
            self?.objectWillChange.send()
        }).store(in: &subscriptions)
        
        // This causes to update publish changes from withing view updates, for now wrapped in queue
        payManager.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }.store(in: &subscriptions)
        
    }
    
    //TODO: ENCAPSULATE TO FUNC SO THE RANGES CAN BE USED, REFRESH BASED ON VIEW PICKER (1D, 1W, 1M, 1Y AND SO ON)
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


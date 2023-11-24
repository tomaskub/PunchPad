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
    typealias Period = (Date, Date)
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
    
    //MARK: PUBLISHED VARIABLES
    @Published var chartTimeRange: ChartTimeRange = .week
    @Published var periodDisplayed: Period = (Date(), Date())
    //TODO: WRAP IN MODEL STRUCT
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
    
    /// Generate Period (touple of dates)  encompasing given time range, containing date
    /// - Parameters:
    ///     - calendar: the calendar used to establish the date periods (default calendar is .current)
    ///     - date: the date that the period contains
    ///     - timeRange:  time range that should be encompased in period
    /// - Returns: a touple of start date and end date of the period
    func generatePeriod(with calendar: Calendar = .current, for date: Date, in timeRange: ChartTimeRange) -> Period {
        let dateComponents = {
            switch timeRange {
            case .week:
                return calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
            case .month:
                return calendar.dateComponents([.month, .year], from: date)
            case .year:
                return calendar.dateComponents([.year], from: date)
            case .all:
                //TODO: REPLACE WITH FIRST ENTRY IN DATA MANAGER
                return calendar.dateComponents([.quarter], from: date)
            }
        }()
        let startDate: Date = calendar.date(from: dateComponents)!
        let numberOfDays: Int = {
            switch timeRange {
            case .week:
                return 6
            case .month:
                return calendar.range(of: .day, in: .month, for: startDate)!.count - 1
            case .year:
                return calendar.range(of: .day, in: .year, for: startDate)!.count - 1
            case .all:
                return calendar.range(of: .day, in: .quarter, for: startDate)!.count
            }
        }()
        let finishDate: Date = calendar.date(byAdding: .day, value: numberOfDays, to: startDate)!
        return (startDate, finishDate)
    }
    
    func decreasePeriod(with calendar: Calendar = .current, by timeRange: ChartTimeRange, from currentPeriod: Period) -> Period {
        let numberOfDays: Int = {
            switch timeRange {
            case .week:
                return 6
            case .month:
                return calendar.range(of: .day, in: .month, for: currentPeriod.0)!.count - 1
            case .year:
                return calendar.range(of: .day, in: .year, for: currentPeriod.0)!.count - 1
            case .all:
                return calendar.range(of: .day, in: .quarter, for: currentPeriod.0)!.count
            }
        }()
        let newPeriodStartDate = calendar.date(byAdding: .day, value: -numberOfDays, to: currentPeriod.0)!
        let newPeriodFinishDate = calendar.date(byAdding: .day, value: -numberOfDays, to: currentPeriod.1)!
        return (newPeriodStartDate, newPeriodFinishDate)
    }
}


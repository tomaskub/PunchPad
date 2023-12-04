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


typealias Period = (Date, Date)
class StatisticsViewModel: ObservableObject {
    private var chartPeriodService: ChartPeriodService = .init(calendar: .current)
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
        do {
            self.periodDisplayed = try chartPeriodService.generatePeriod(for: Date(), in: chartTimeRange)
        } catch {
            print("Error while getting initial period")
        }
        dataManager.objectWillChange.sink(receiveValue: { [weak self] _ in
            self?.objectWillChange.send()
        }).store(in: &subscriptions)
        
        // This causes to update publish changes from withing view updates, for now wrapped in queue
        payManager.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }.store(in: &subscriptions)
        
        $chartTimeRange
            .removeDuplicates()
            .sink { [weak self] timeRange in
                guard let self else { return }
                do {
                    // when changing to lwoer range date it is not working great - maybe use current date if there is no period change?
                    let midDate = try self.chartPeriodService.returnPeriodMidDate(for: periodDisplayed)
                    self.periodDisplayed = try self.chartPeriodService.generatePeriod(for: midDate, in: timeRange)
                } catch ChartPeriodServiceError.attemptedToRetrievePeriodForAll {
                    //TODO: IMPLEMENT RETRIEVING ALL OF THE DATA
                    print("Failed to generate chart time period becouse `all` was selected")
                } catch {
                    print("Failed to generate chart time period with new range")
                }
            }.store(in: &subscriptions)
    }
    
    ///Entries for use with a chart - contains empy entries for days without the entry in this monts
    var entriesForChart: [Entry] {
        let placeholderArray: [Entry] = createPlaceholderEntries(for: periodDisplayed)
        return replacePlaceholderEntries(placeholderArray)
    }
    
    func createPlaceholderEntries(for period: Period) -> [Entry] {
        var placeholders: [Entry] = []
        let numberOfDaysInPeriod = Calendar.current.dateComponents([.day], from: period.0, to: period.1).day!
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: period.0)
        for day in 0...numberOfDaysInPeriod {
            var currentDateComponents = dateComponents
            currentDateComponents.day = dateComponents.day! + day
            let date = Calendar.current.date(from: currentDateComponents)!
            let placeholderEntry = Entry(
                startDate: date,
                finishDate: date,
                workTimeInSec: 0,
                overTimeInSec: 0
            )
            placeholders.append(placeholderEntry)
        }
        return placeholders
    }
    
    func replacePlaceholderEntries(_ placeholders: [Entry]) -> [Entry] {
        guard let fetchedEntries = dataManager.fetch(for: periodDisplayed) else { return placeholders }
        let result = placeholders.map { placeholder in
            let replacer = fetchedEntries.first { entry in
                let dateComponentsToCompare: Set<Calendar.Component> = [.day, .month, .year]
                return Calendar.current.dateComponents(dateComponentsToCompare, from: entry.startDate) == Calendar.current.dateComponents(dateComponentsToCompare, from: placeholder.startDate)
            }
            return replacer ?? placeholder
        }
        return result
    }
}

//MARK: CHART DATA FUNCTIONS
extension StatisticsViewModel {
    
    func loadPreviousPeriod() {
        do {
            periodDisplayed = try chartPeriodService.retardPeriod(by: chartTimeRange, from: periodDisplayed)
        } catch {
            print("Failed to load previous period")
        }
    }
    
    func loadNextPeriod() {
        do {
            periodDisplayed = try chartPeriodService.advancePeriod(by: chartTimeRange, from: periodDisplayed)
        } catch {
            print("Failed to load next period")
        }
    }
}

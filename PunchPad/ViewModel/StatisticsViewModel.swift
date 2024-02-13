//
//  StatisticsViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import Foundation
import Combine

class StatisticsViewModel: ObservableObject {
    private var chartPeriodService: ChartPeriodService
    private var calendar: Calendar
    @Published private var dataManager: DataManager
    @Published private var payManager: PayManager
    @Published private var settingsStore: SettingsStore
    private var subscriptions = Set<AnyCancellable>()
    //MARK: PUBLISHED VARIABLES
    @Published var chartTimeRange: ChartTimeRange = .week
    @Published var periodDisplayed: Period = (Date(), Date())
    var grossSalaryData: GrossSalary {
        payManager.grossDataForPeriod
    }
    
    var workedHoursInPeriod: Int {
        entryInPeriod.map { entry in
            (entry.workTimeInSeconds + entry.overTimeInSeconds ) / 3600
        }.reduce(0, +)
    }
    
    var overtimeHoursInPeriod: Int {
        entryInPeriod.map { entry in
            entry.overTimeInSeconds / 3600
        }.reduce(0, +)
    }
    
    ///Entries for use with a chart - contains empy entries for days without the entry in this monts
    @Published var entryInPeriod: [Entry]
    
    var entrySummaryByMonthYear: [EntrySummary] {
        groupEntriesByYearMonth(entryInPeriod).map { EntrySummary(fromEntries: $0) }
    }
    
    var entrySummaryByWeekYear: [EntrySummary]? {
        guard let startDate = entryInPeriod.first?.startDate,
              let finishDate = entryInPeriod.last?.finishDate,
              let timeDiff = Calendar.current.dateComponents([.month], from: startDate, to: finishDate).month,
              timeDiff < 3,
              entryInPeriod.count < 60 else { return nil }
        return groupEntriesByYearWeek(entryInPeriod).map { EntrySummary(fromEntries: $0) }
    }
    
    init(dataManager: DataManager, payManager: PayManager, settingsStore: SettingsStore, calendar: Calendar) {
        self.dataManager = dataManager
        self.payManager = payManager
        self.settingsStore = settingsStore
        self.calendar = calendar
        self.chartPeriodService = ChartPeriodService(calendar: calendar)
        
        self.entryInPeriod = []
        do {
            self.periodDisplayed = try chartPeriodService.generatePeriod(for: Date(), in: chartTimeRange)
        } catch {
            print("Error while getting initial period")
        }
        
        setPayManagerSubscriber()
        setPeriodUpdatingSubscriber()
        setEntryDataUpdatingSubscribers()
    }
    
    func setPayManagerSubscriber() {
        payManager.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }.store(in: &subscriptions)
    }
    
    func setPeriodUpdatingSubscriber() {
        $chartTimeRange
            .removeDuplicates()
            .sink { [weak self] timeRange in
                guard let self else { return }
                switch timeRange {
                case .week, .month, .year:
                    do {
                        let midDate = try self.chartPeriodService.returnPeriodMidDate(for: periodDisplayed)
                        self.periodDisplayed = try self.chartPeriodService.generatePeriod(for: midDate, in: timeRange)
                        self.payManager.updatePeriod(with: self.periodDisplayed)
                    } catch ChartPeriodServiceError.attemptedToRetrievePeriodForAll {
                        print("Failed to generate chart time period becouse `all` was selected")
                    } catch {
                        print("Failed to generate chart time period with new range")
                    }
                case .all:
                    if let firstEntry = dataManager.fetchOldestExisting(),
                       let lastEntry = dataManager.fetchNewestExisting() {
                        do {
                            self.periodDisplayed = try self.chartPeriodService.generatePeriod(from: firstEntry, to: lastEntry)
                            self.payManager.updatePeriod(with: self.periodDisplayed)
                        } catch {
                            print("Failed to generate chart time period with new `.all` range")
                        }
                    } else {
                        print("Failed to generate chart time period with new `.all` range when retrieving first and last entry")
                    }
                }
            }.store(in: &subscriptions)
    }
    
    func setEntryDataUpdatingSubscribers() {
        $periodDisplayed
            .removeDuplicates { lhs, rhs in
                return lhs.0 == rhs.0 && lhs.1 == rhs.1
            }
            .receive(on: RunLoop.main)
            .map { [weak self] period in
                guard let self else { return [] }
                return self.fetchEntriesWithPlaceholders(for: period)
            }.assign(to: &$entryInPeriod)
        
        dataManager.objectWillChange.sink { [weak self] _ in
            guard let self else { return }
            self.entryInPeriod = self.fetchEntriesWithPlaceholders(for: periodDisplayed)
        }.store(in: &subscriptions)
        
    }
}

extension StatisticsViewModel {
    private func fetchEntriesWithPlaceholders(for period: Period) -> [Entry] {
        guard let numberOfDaysInPeriod = calendar.dateComponents([.day], from: period.0, to: period.1).day,
              numberOfDaysInPeriod > 0 else { return [] }
        let placeholders = [Int](0..<numberOfDaysInPeriod)
            .compactMap { i in
                calendar.date(byAdding: .day, value: i, to: period.0)
            }.map { date in
                Entry(startDate: date,
                      finishDate: date,
                      workTimeInSec: 0,
                      overTimeInSec: 0,
                      maximumOvertimeAllowedInSeconds: settingsStore.maximumOvertimeAllowedInSeconds,
                      standardWorktimeInSeconds: settingsStore.workTimeInSeconds,
                      grossPayPerMonth: settingsStore.grossPayPerMonth,
                      calculatedNetPay: nil
                )
            }
        guard let fetchedEntries = dataManager.fetch(for: period) else {
            return placeholders
        }
        return placeholders.map { placeholder in
            let placeholderDateComponents = self.calendar.dateComponents([.day,.month,.year], from: placeholder.startDate)
            let replacer = fetchedEntries.first { self.calendar.date($0.startDate, matchesComponents: placeholderDateComponents) }
            return replacer ?? placeholder
        }
    }
}
//MARK: DATA GROUPING FUNCTIONS
extension StatisticsViewModel {
    private func groupEntriesByYearMonth(_ entries: [Entry]) -> [[Entry]] {
        var result: [[Entry]] = .init()
        
        var currentYearMonth: DateComponents?
        var currentEntries: [Entry] = .init()
        
        for entry in entries {
            let entryDateComponents = Calendar.current.dateComponents([.month,.year], from: entry.startDate)
            if entryDateComponents != currentYearMonth {
                if !currentEntries.isEmpty {
                    result.append(currentEntries)
                }
                currentEntries = [entry]
                currentYearMonth = entryDateComponents
            } else {
                currentEntries.append(entry)
            }
        }
        if !currentEntries.isEmpty {
            result.append(currentEntries)
        }
        return result
    }
    
    private func groupEntriesByYearWeek(_ entries: [Entry]) -> [[Entry]] {
        var result = [[Entry]]()
        var currentYearWeek: DateComponents?
        var currentEntries: [Entry] = .init()
        for entry in entries {
            let entryDateComponents = Calendar.current.dateComponents([.weekOfYear, .yearForWeekOfYear], from: entry.startDate)
            if entryDateComponents != currentYearWeek {
                if !currentEntries.isEmpty {
                    result.append(currentEntries)
                }
                currentEntries = [entry]
                currentYearWeek = entryDateComponents
            } else {
                currentEntries.append(entry)
            }
        }
        if !currentEntries.isEmpty {
            result.append(currentEntries)
        }
        return result
    }
}

//MARK: CHART DATA FUNCTIONS
extension StatisticsViewModel {
    
    func loadPreviousPeriod() {
        guard self.chartTimeRange != .all else { return }
        do {
            periodDisplayed = try chartPeriodService.retardPeriod(by: chartTimeRange, from: periodDisplayed)
            payManager.updatePeriod(with: periodDisplayed)
        } catch {
            print("Failed to load previous period")
        }
    }
    
    func loadNextPeriod() {
        guard self.chartTimeRange != .all else { return }
        do {
            periodDisplayed = try chartPeriodService.advancePeriod(by: chartTimeRange, from: periodDisplayed)
            payManager.updatePeriod(with: periodDisplayed)
        } catch {
            print("Failed to load next period")
        }
    }
}

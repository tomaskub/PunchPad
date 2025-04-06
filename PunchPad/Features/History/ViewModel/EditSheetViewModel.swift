//
//  EditShetViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/18/23.
//

import DomainModels
import Foundation
import Combine
import OSLog

final class EditSheetViewModel: ObservableObject {
    private var logger = Logger.editSheetViewModel
    private var dataManager: any DataManaging
    private var settingsStore: SettingsStore
    private var payService: PayManager
    private var entry: Entry
    private let calendar: Calendar
    private var cancellables: Set<AnyCancellable> = .init()
    @Published var startDate: Date
    @Published var finishDate: Date
    @Published var workTimeInSeconds: TimeInterval
    @Published var overTimeInSeconds: TimeInterval
    @Published var currentMaximumOvertime: TimeInterval
    @Published var currentStandardWorkTime: TimeInterval
    @Published var grossPayPerMonth: Int
    @Published var calculateNetPay: Bool
    @Published var shouldDisplayFullDates: Bool
    var totalTimeInSeconds: TimeInterval {
        TimeInterval(workTimeInSeconds + overTimeInSeconds)
    }
    var breakTime: TimeInterval {
        guard startDate < finishDate else { return 0 }
        let timeFromDates = DateInterval(start: startDate, end: finishDate).duration
        if timeFromDates > workTimeInSeconds + overTimeInSeconds {
            return timeFromDates - workTimeInSeconds - overTimeInSeconds
        } else {
            return 0
        }
    }
    var workTimeFraction: CGFloat {
        CGFloat(workTimeInSeconds / currentStandardWorkTime)
    }
    var overTimeFraction: CGFloat {
        CGFloat(overTimeInSeconds / currentMaximumOvertime)
    }
    
    init(dataManager: any DataManaging,
         settingsStore: SettingsStore,
         payService: PayManager,
         calendar: Calendar = .current,
         entry: Entry) {
        self.dataManager = dataManager
        self.settingsStore = settingsStore
        self.payService = payService
        self.entry = entry
        self.calendar = calendar
        self.startDate = entry.startDate
        self.finishDate = entry.finishDate
        self.workTimeInSeconds = TimeInterval(entry.workTimeInSeconds)
        self.overTimeInSeconds = TimeInterval(entry.overTimeInSeconds)
        self.currentMaximumOvertime = TimeInterval(entry.maximumOvertimeAllowedInSeconds)
        self.currentStandardWorkTime = TimeInterval(entry.standardWorktimeInSeconds)
        self.grossPayPerMonth = entry.grossPayPerMonth
        self.calculateNetPay = entry.calculatedNetPay == nil ? false : true
        self.shouldDisplayFullDates = {
            let startDateComponents = calendar.dateComponents([.year, .month, .day], from: entry.startDate)
            if calendar.date(entry.finishDate, matchesComponents: startDateComponents) {
                return false
            } else {
                return true
            }
        }()
        setTimeCalculationPipelines()
        setOverrideTimePipelines()
        setDateMatchingPipeline()
    }
    
    private func setOverrideTimePipelines() {
        logger.debug("setOverrideTimePipelines called")
        $currentStandardWorkTime
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] workTime in
                guard let self else { return }
                self.adjustTimeSplit(workTime, currentMaximumOvertime)
            }.store(in: &cancellables)
        
        $currentMaximumOvertime
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] overtime in
                guard let self else { return }
                self.adjustTimeSplit(currentStandardWorkTime, overtime)
            }.store(in: &cancellables)
    }
    
    private func setTimeCalculationPipelines() {
        logger.debug("setTimeCalculationPipelines called")
        $finishDate
            .dropFirst()
            .removeDuplicates()
            .filter { [weak self] newValue in
                guard let self else { return false }
                let oldValueComponents = self.calendar.dateComponents([.year, .month, .day], from: self.finishDate)
                return self.calendar.date(newValue,
                                          matchesComponents: oldValueComponents) || self.shouldDisplayFullDates
            }
            .sink { [weak self] date in
                guard let self else { return }
                self.calculateTime(self.startDate, date)
            }.store(in: &cancellables)
        
        $startDate
            .dropFirst()
            .removeDuplicates()
            .filter { [weak self] newValue in
                guard let self else { return false }
                let oldValueComponents = self.calendar.dateComponents([.year, .month, .day],
                                                                      from: self.startDate)
                return self.calendar.date(newValue,
                                          matchesComponents: oldValueComponents) || self.shouldDisplayFullDates
            }
            .sink { [weak self] date in
                guard let self else { return }
                self.calculateTime(date, self.finishDate)
            }.store(in: &cancellables)
    }

    private func setDateMatchingPipeline() {
        logger.debug("setDateMatchingPipeline called")
        $shouldDisplayFullDates
            .dropFirst()
            .removeDuplicates()
            .filter({ value in
                return !value
            })
            .map { _ in
                let newDate = self.adjustToEqualDateComponents([.year, .month, .day],
                                                               from: self.startDate,
                                                               to: self.finishDate,
                                                               using: self.calendar)
                if newDate.timeIntervalSince1970 < self.startDate.timeIntervalSince1970 {
                    return self.startDate
                } else {
                    return newDate
                }
            }.assign(to: &$finishDate)
    }
    
    /// Adjust component in target date to match components in source date
    ///  Minimum resultion to which the date will be adjusted is `.second`.
    ///  Components allowed to be used in set are `.year`, `.month`, `.day`, `.hour`, `.minute` and `.second`
    private func adjustToEqualDateComponents(_ calendarComponents: Set<Calendar.Component>,
                                             from source: Date,
                                             to target: Date,
                                             using calendar: Calendar) -> Date {
        let allowedCalendarComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let changedDateComponents = calendar.dateComponents(calendarComponents, from: source)
        let unchangedDateComponents = calendar.dateComponents(allowedCalendarComponents.subtracting(calendarComponents),
                                                              from: target)
        var resultDateComponents = DateComponents()
        for calendarComponent in allowedCalendarComponents {
            guard let keyPath = calendarComponent.dateComponentKeyPath else { continue }
            if calendarComponents.contains(calendarComponent) {
                resultDateComponents[keyPath: keyPath] = changedDateComponents[keyPath: keyPath]
            } else {
                resultDateComponents[keyPath: keyPath] = unchangedDateComponents[keyPath: keyPath]
            }
        }
        return calendar.date(from: resultDateComponents) ?? target
    }
    
    /// Calculate time for the entry and allot it to workTime and overTime
    private func calculateTime(_ startDate: Date, _ finishDate: Date) {
        guard startDate < finishDate else { return }
        let interval = DateInterval(start: startDate, end: finishDate)
        if interval.duration <= currentStandardWorkTime {
            workTimeInSeconds = interval.duration
            overTimeInSeconds = 0
        } else if interval.duration - currentStandardWorkTime < currentMaximumOvertime {
            workTimeInSeconds = currentStandardWorkTime
            overTimeInSeconds = interval.duration - currentStandardWorkTime
        } else {
            workTimeInSeconds = currentStandardWorkTime
            overTimeInSeconds = currentMaximumOvertime
        }
    }
    
    /// Adjust existing total time recorded in entry into work time and overtime given
    private func adjustTimeSplit(_ standardWorkTime: TimeInterval, _ maximumOvertime: TimeInterval) {
        let interval = totalTimeInSeconds
        if interval <= standardWorkTime {
            workTimeInSeconds = interval
            overTimeInSeconds = 0
        } else if interval - standardWorkTime < maximumOvertime {
            workTimeInSeconds = standardWorkTime
            overTimeInSeconds = interval - standardWorkTime
        } else {
            workTimeInSeconds = standardWorkTime
            overTimeInSeconds = maximumOvertime
        }
    }
    
    /// Save entry constructed from data published by view model
    func saveEntry() {
        logger.debug("saveEntry called")
        entry.startDate = startDate
        entry.finishDate = finishDate
        entry.workTimeInSeconds = Int(workTimeInSeconds)
        entry.overTimeInSeconds = Int(overTimeInSeconds)
        entry.maximumOvertimeAllowedInSeconds = Int(currentMaximumOvertime)
        entry.standardWorktimeInSeconds = Int(currentStandardWorkTime)
        entry.grossPayPerMonth = grossPayPerMonth
        entry.calculatedNetPay = calculateNetPay ? payService.calculateNetPay(gross: Double(grossPayPerMonth)) : nil
        dataManager.updateAndSave(entry: entry)
    }
}

//
//  EditShetViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/18/23.
//

import Foundation
import Combine

final class EditSheetViewModel: ObservableObject {
    private var dataManager: DataManager
    private var settingsStore: SettingsStore
    private var payService: PayManager
    private var entry: Entry
    private let calendar: Calendar
    private var cancellables: Set<AnyCancellable> = .init()
    //MARK: ENTRY PROPERTIES
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
    var workTimeFraction: CGFloat {
        CGFloat(workTimeInSeconds / currentStandardWorkTime)
    }
    var overTimeFraction: CGFloat {
        CGFloat(overTimeInSeconds / currentMaximumOvertime)
    }
    
    init(dataManager: DataManager,  settingsStore: SettingsStore, payService: PayManager, calendar: Calendar = .current, entry: Entry) {
        self.dataManager = dataManager
        self.settingsStore = settingsStore
        self.payService = payService
        self.entry = entry
        self.calendar = calendar
        //assign values to draft properties
        self.startDate = entry.startDate
        self.finishDate = entry.finishDate
        self.workTimeInSeconds = TimeInterval(entry.workTimeInSeconds)
        self.overTimeInSeconds = TimeInterval(entry.overTimeInSeconds)
        self.currentMaximumOvertime = TimeInterval(entry.maximumOvertimeAllowedInSeconds)
        self.currentStandardWorkTime = TimeInterval(entry.standardWorktimeInSeconds)
        self.grossPayPerMonth = entry.grossPayPerMonth
        self.calculateNetPay = entry.calculatedNetPay == nil ? false : true
        
        self.shouldDisplayFullDates = {
            if let hours = calendar.dateComponents([.hour], from: entry.startDate).hour {
                if hours >= 24 - (entry.standardWorktimeInSeconds / 3600) {
                            return true
                        }
                    }
            return false
        }()
        // set up combine pipelines
        setDateMatchingPipeline()
        setTimeCalculationPipelines()
        setOverrideTimePipelines()
        setDisplayingFullDatesPipeline()
    }
    
    private func setOverrideTimePipelines() {
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
        $finishDate
            .dropFirst()
            .removeDuplicates()
        // run calculate changes only when time components change
            .filter { [weak self] newValue in
                guard let self else { return false }
                let oldValueComponents = Calendar.current.dateComponents([.year, .month, .day], from: self.finishDate)
                return Calendar.current.date(newValue, matchesComponents: oldValueComponents) || self.shouldDisplayFullDates
            }
            .sink { [weak self] date in
                guard let self else { return }
                self.calculateTime(self.startDate, date)
            }.store(in: &cancellables)
        
        $startDate
            .dropFirst()
            .removeDuplicates()
        // run calculate changes only when time components change
            .filter { [weak self] newValue in
                guard let self else { return false }
                let oldValueComponents = Calendar.current.dateComponents([.year, .month, .day], from: self.startDate)
                return Calendar.current.date(newValue, matchesComponents: oldValueComponents) || self.shouldDisplayFullDates
            }
            .sink { [weak self] date in
                guard let self else { return }
                self.calculateTime(date, self.finishDate)
            }.store(in: &cancellables)
    }

    private func setDateMatchingPipeline() {
        $startDate
            .dropFirst()
            .removeDuplicates()
            .filter {  _ in
                self.shouldDisplayFullDates
            }
            .map { date in
                self.adjustToEqualDateComponents([.year, .month, .day], from: date, to: self.finishDate, using: self.calendar)
            }.assign(to: &$finishDate)
    }
    
    private func setDisplayingFullDatesPipeline() {
        $startDate
            .dropFirst()
            .removeDuplicates()
            .filter { _ in
                !self.shouldDisplayFullDates
            }
            .map { [weak self] dateValue in
                if let hours = self?.calendar.dateComponents([.hour], from: dateValue).hour,
                   let worktimeInterval = self?.currentStandardWorkTime {
                    if hours >= 24 - Int(worktimeInterval / 3600) {
                        return true
                    }
                }
                return false
            }.assign(to: &$shouldDisplayFullDates)
        
        $startDate
            .filter { _ in
                self.shouldDisplayFullDates
            }
            .map { [weak self] date in
                guard let self else { return false }
                let dateComponents = self.calendar.dateComponents([.year, .month, .day], from: date)
                let isMatchingFinishDate = self.calendar.date(self.finishDate, matchesComponents: dateComponents)
                return !isMatchingFinishDate
            }
            .assign(to: &$shouldDisplayFullDates)
        
        $finishDate
            .filter { _ in
                self.shouldDisplayFullDates
            }
            .map { [weak self] date in
                guard let self else { return false }
                let dateComponents = self.calendar.dateComponents([.year, .month, .day], from: date)
                let isMatchingStartDate = self.calendar.date(self.startDate, matchesComponents: dateComponents)
                return !isMatchingStartDate
            }
            .assign(to: &$shouldDisplayFullDates)
        
    }
    
    /// Adjust component in target date to match components in source date
    /// - Parameters:
    ///   - calendarComponents: set of calendar components that should be changed
    ///   - source: date from which to take components
    ///   - target: date to which set the components to match
    ///   - calendar: calendar instance used for date manipulation
    /// - Returns: Date with adjusted components or unchanged component if date creation failed
    ///
    ///  Minimum resultion to which the date will be adjusted is `.second`.
    ///  Components allowed to be used in set are `.year`, `.month`, `.day`, `.hour`, `.minute` and `.second`
    private func adjustToEqualDateComponents(_ calendarComponents: Set<Calendar.Component>, from source: Date, to target: Date, using calendar: Calendar) -> Date {
        let allowedCalendarComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let changedDateComponents = calendar.dateComponents(calendarComponents, from: source)
        let unchangedDateComponents = calendar.dateComponents(allowedCalendarComponents.subtracting(calendarComponents), from: target)
        
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
    /// - Parameters:
    ///   - startDate: date at which work was started
    ///   - finishDate: date at which work was finished
    private func calculateTime(_ startDate: Date, _ finishDate: Date) {
        guard startDate < finishDate else { return }
        let interval = DateInterval(start: startDate, end: finishDate)
        if interval.duration <= currentStandardWorkTime {
            workTimeInSeconds = interval.duration
            overTimeInSeconds = 0
        } else if interval.duration - currentStandardWorkTime < currentMaximumOvertime{
            workTimeInSeconds = currentStandardWorkTime
            overTimeInSeconds = interval.duration - currentStandardWorkTime
        } else {
            workTimeInSeconds = currentStandardWorkTime
            overTimeInSeconds = currentMaximumOvertime
        }
    }
    
    /// Adjust existing total time recorded in entry into work time and overtime based on new values.
    /// - Parameters:
    ///   - standardWorkTime: standard worktime for the entry
    ///   - maximumOvertime: maximum overtime allowed for the entry
    ///
    /// Used when overriding setttings. Does not affect date in entry. If the time currently stored exceeds new maximum (sum of standard and overtime), it is set to new maximum.
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
        entry.startDate = startDate
        entry.finishDate = finishDate
        entry.workTimeInSeconds = Int(workTimeInSeconds)
        entry.overTimeInSeconds = Int(overTimeInSeconds)
        entry.maximumOvertimeAllowedInSeconds = Int(currentMaximumOvertime)
        entry.standardWorktimeInSeconds = Int(currentMaximumOvertime)
        entry.grossPayPerMonth = grossPayPerMonth
        entry.calculatedNetPay = calculateNetPay ? payService.calculateNetPay(gross: Double(grossPayPerMonth)) : nil
        dataManager.updateAndSave(entry: entry)
    }
}
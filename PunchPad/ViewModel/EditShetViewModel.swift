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
    var breakTime: TimeInterval {
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
        setTimeCalculationPipelines()
        setOverrideTimePipelines()
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
        entry.standardWorktimeInSeconds = Int(currentStandardWorkTime)
        entry.grossPayPerMonth = grossPayPerMonth
        entry.calculatedNetPay = calculateNetPay ? payService.calculateNetPay(gross: Double(grossPayPerMonth)) : nil
        dataManager.updateAndSave(entry: entry)
    }
}

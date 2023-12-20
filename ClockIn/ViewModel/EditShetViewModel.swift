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
    private var entry: Entry
    private var cancellables: Set<AnyCancellable> = .init()
    //MARK: ENTRY PROPERTIES
    @Published var startDate: Date
    @Published var finishDate: Date
    @Published var workTimeInSeconds: TimeInterval
    @Published var overTimeInSeconds: TimeInterval
    @Published var currentMaximumOvertime: TimeInterval
    @Published var currentStandardWorkTime: TimeInterval
    //TODO: CHANGE TO INT PROPERTY WITH TEXTFIELD NUMBER ONLY
    @Published var grossPayPerMonth = String()
    @Published var calculateNetPay: Bool
    
    var totalTimeInSeconds: TimeInterval {
        TimeInterval(workTimeInSeconds + overTimeInSeconds)
    }
    
    var shouldDisplayFullDates: Bool {
        if let hours = Calendar.current.dateComponents([.hour], from: startDate).hour {
            if hours >= 16 {
                return true
            }
        }
        return false
    }
    
    var workTimeFraction: CGFloat {
        CGFloat(workTimeInSeconds / currentStandardWorkTime)
    }
    var overTimeFraction: CGFloat {
        CGFloat(overTimeInSeconds / currentMaximumOvertime)
    }
    
    init(dataManager: DataManager,  settingsStore: SettingsStore, entry: Entry) {
        self.dataManager = dataManager
        self.settingsStore = settingsStore
        self.entry = entry
        //assign values to draft properties
        self.startDate = entry.startDate
        self.finishDate = entry.finishDate
        self.workTimeInSeconds = TimeInterval(entry.workTimeInSeconds)
        self.overTimeInSeconds = TimeInterval(entry.overTimeInSeconds)
        self.currentMaximumOvertime = TimeInterval(entry.maximumOvertimeAllowedInSeconds)
        self.currentStandardWorkTime = TimeInterval(entry.standardWorktimeInSeconds)
        self.grossPayPerMonth = String(entry.grossPayPerMonth)
        self.calculateNetPay = entry.calculatedNetPay == nil ? false : true
        
        $finishDate
            .removeDuplicates()
            .sink { [weak self] date in
                guard let self else { return }
                self.calculateTime(self.startDate, date)
            }.store(in: &cancellables)
        
        $startDate
            .removeDuplicates()
            .sink { [weak self] date in
                guard let self else { return }
                self.calculateTime(date, self.finishDate)
            }.store(in: &cancellables)
    }
    
    // calculating time intervals
    private func calculateTime(_ startDate: Date, _ finishDate: Date) {
        let interval = DateInterval(start: startDate, end: finishDate)
        if interval.duration <= currentStandardWorkTime {
            workTimeInSeconds = interval.duration
            overTimeInSeconds = 0
        } else {
            workTimeInSeconds = currentStandardWorkTime
            overTimeInSeconds = interval.duration - currentStandardWorkTime
        }
    }
    
    func saveEntry() {
        //TODO: ADD PAY SERVICE TO SAVE THE NET PAY
        entry.startDate = startDate
        entry.finishDate = finishDate
        entry.workTimeInSeconds = Int(workTimeInSeconds)
        entry.overTimeInSeconds = Int(overTimeInSeconds)
        entry.maximumOvertimeAllowedInSeconds = Int(currentMaximumOvertime)
        entry.standardWorktimeInSeconds = Int(currentMaximumOvertime)
        entry.grossPayPerMonth = Int(grossPayPerMonth) ?? 0
        entry.calculatedNetPay = calculateNetPay ? 0.0 : nil
        dataManager.updateAndSave(entry: entry)
    }
    
}

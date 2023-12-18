//
//  EditShetViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/18/23.
//

import Foundation

final class EditSheetViewModel: ObservableObject {
    
    private var dataManager: DataManager
    private var settingsStore: SettingsStore
    private var entry: Entry
    private var workTimeAllowed: Int {
        settingsStore.workTimeInSeconds
    }
    private var overTimeAllowed: Int {
        settingsStore.maximumOvertimeAllowedInSeconds
    }
    let dateComponentFormatter = { 
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
    
    @Published var startDate: Date {
        didSet {
            calculateTime()
        }
    }
    @Published var finishDate: Date {
        didSet {
            calculateTime()
        }
    }
    
    private var workTimeInSeconds: Int {
        didSet {
            workTimeString = generateTimeIntervalLabel(value: TimeInterval(workTimeInSeconds))
            workTimeFraction = CGFloat(workTimeInSeconds) / CGFloat(workTimeAllowed)
        }
    }
    
    private var overTimeInSeconds: Int {
        didSet {
            overTimerString = generateTimeIntervalLabel(value: TimeInterval(overTimeInSeconds))
            overTimeFraction = CGFloat(overTimeInSeconds) / CGFloat(overTimeAllowed)
        }
    }
    
    @Published var shouldDisplayFullDates: Bool = false
    @Published var totalTimeWorked: String
    @Published var workTimeString: String
    @Published var overTimerString: String
    @Published var workTimeFraction: CGFloat
    @Published var overTimeFraction: CGFloat
    
    init(dataManager: DataManager,  settingsStore: SettingsStore, entry: Entry) {
        self.dataManager = dataManager
        self.settingsStore = settingsStore
        self.entry = entry
        
        self.startDate = entry.startDate
        self.finishDate = entry.finishDate
        self.workTimeInSeconds = entry.workTimeInSeconds
        self.overTimeInSeconds = entry.overTimeInSeconds
        
        self.totalTimeWorked = String()
        self.workTimeString = String()
        self.overTimerString = String()

        self.workTimeFraction = CGFloat(workTimeInSeconds) / CGFloat(settingsStore.workTimeInSeconds)
        self.overTimeFraction = CGFloat(overTimeInSeconds) / CGFloat(settingsStore.maximumOvertimeAllowedInSeconds)
        
        self.workTimeString = generateTimeIntervalLabel(value: TimeInterval(workTimeInSeconds))
        self.overTimerString = generateTimeIntervalLabel(value: TimeInterval(overTimeInSeconds))
        self.totalTimeWorked = generateTimeIntervalLabel(value: TimeInterval(workTimeInSeconds + overTimeInSeconds))
        
    }
    
    private func calculateTime() {
        let timeInterval = Calendar.current.dateComponents([.second], from: startDate, to: finishDate)
        if let seconds = timeInterval.second {
            if seconds <= workTimeAllowed {
                workTimeInSeconds = seconds
                overTimeInSeconds = 0
            } else {
                workTimeInSeconds = workTimeAllowed
                overTimeInSeconds = seconds - workTimeAllowed
            }
        }
    }
    
    private func generateTimeIntervalLabel(value: TimeInterval) -> String {
        return dateComponentFormatter.string(from: value)!
    }
    
    func saveEntry() {
        entry.startDate = startDate
        entry.finishDate = finishDate
        entry.workTimeInSeconds = workTimeInSeconds
        entry.overTimeInSeconds = overTimeInSeconds
        dataManager.updateAndSave(entry: entry)
        
    }
    
}

//
//  EditShetViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/18/23.
//

import Foundation
//TODO: CLEAN UP MESS
final class EditSheetViewModel: ObservableObject {
    
    private var dataManager: DataManager
    private var settingsStore: SettingsStore
    private var entry: Entry
    
    // Data retrieved from the setting store - should be obsolete
    private var workTimeAllowed: Int {
        settingsStore.workTimeInSeconds
    }
    private var overTimeAllowed: Int {
        settingsStore.maximumOvertimeAllowedInSeconds
    }
    
    // formatter should move to view since its responsible for view
    let dateComponentFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
    
    // placeholder properties
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
    // placeholder properties created with calculate time? - need to remove side effects or set up as combine pipeline
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
    
    // should move to view?
    @Published var shouldDisplayFullDates: Bool = false
    @Published var totalTimeWorked: String
    @Published var workTimeString: String
    @Published var overTimerString: String
    @Published var workTimeFraction: CGFloat
    @Published var overTimeFraction: CGFloat
    //think about joining the overtime properties or making it less spaghetti
    var currentMaximumOvertime: TimeInterval {
        TimeInterval(overTimeInSeconds)
    }
    var currentStandardWorkTime: TimeInterval {
        TimeInterval(workTimeInSeconds)
    }
    // stuff for overriding settings, it now overrides the actual time but let it live
    @Published var maximumOvertime = (Int(), Int()) {
        didSet {
            overTimeInSeconds = maximumOvertime.0 * 3600 + maximumOvertime.1 * 60
        }
    }
    
    @Published var standardWorkTime = (Int(), Int()) {
        didSet {
            workTimeInSeconds = standardWorkTime.0 * 3600 + standardWorkTime.1 * 60
        }
    }
    @Published var grossPayPerMonth = String()
    @Published var calculateNetPay: Bool
    // init
    init(dataManager: DataManager,  settingsStore: SettingsStore, entry: Entry) {
        self.dataManager = dataManager
        self.settingsStore = settingsStore
        self.entry = entry
        
        self.startDate = entry.startDate
        self.finishDate = entry.finishDate
        self.workTimeInSeconds = entry.workTimeInSeconds
        self.overTimeInSeconds = entry.overTimeInSeconds
        
        self.grossPayPerMonth = String(entry.grossPayPerMonth)
        if let _ = entry.calculatedNetPay {
            self.calculateNetPay = true
        } else {
            self.calculateNetPay = false
        }
        self.totalTimeWorked = String()
        self.workTimeString = String()
        self.overTimerString = String()

        self.workTimeFraction = CGFloat(workTimeInSeconds) / CGFloat(settingsStore.workTimeInSeconds)
        self.overTimeFraction = CGFloat(overTimeInSeconds) / CGFloat(settingsStore.maximumOvertimeAllowedInSeconds)
        
        self.workTimeString = generateTimeIntervalLabel(value: TimeInterval(workTimeInSeconds))
        self.overTimerString = generateTimeIntervalLabel(value: TimeInterval(overTimeInSeconds))
        self.totalTimeWorked = generateTimeIntervalLabel(value: TimeInterval(workTimeInSeconds + overTimeInSeconds))
        
    }
    
    // calculating time intervals
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
    // move to view
    private func generateTimeIntervalLabel(value: TimeInterval) -> String {
        return dateComponentFormatter.string(from: value)!
    }
    
    // should stay but needs additional properties
    func saveEntry() {
        entry.startDate = startDate
        entry.finishDate = finishDate
        entry.workTimeInSeconds = workTimeInSeconds
        entry.overTimeInSeconds = overTimeInSeconds
        dataManager.updateAndSave(entry: entry)
        
    }
    
}

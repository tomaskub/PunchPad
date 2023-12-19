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
    @Published var workTimeInSeconds: Int {
        didSet {
            workTimeFraction = CGFloat(workTimeInSeconds) / CGFloat(workTimeAllowed)
        }
    }
    
    @Published var overTimeInSeconds: Int {
        didSet {
            overTimeFraction = CGFloat(overTimeInSeconds) / CGFloat(overTimeAllowed)
        }
    }
    var totalTimeInSeconds: TimeInterval {
        TimeInterval(workTimeInSeconds + overTimeInSeconds)
    }
    
    // should move to view?
    @Published var shouldDisplayFullDates: Bool = false
    @Published var workTimeFraction: CGFloat = .init()
    @Published var overTimeFraction: CGFloat = .init()
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

        self.workTimeFraction = CGFloat(workTimeInSeconds) / CGFloat(settingsStore.workTimeInSeconds)
        self.overTimeFraction = CGFloat(overTimeInSeconds) / CGFloat(settingsStore.maximumOvertimeAllowedInSeconds)
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
    
    // should stay but needs additional properties
    func saveEntry() {
        entry.startDate = startDate
        entry.finishDate = finishDate
        entry.workTimeInSeconds = workTimeInSeconds
        entry.overTimeInSeconds = overTimeInSeconds
        dataManager.updateAndSave(entry: entry)
        
    }
    
}

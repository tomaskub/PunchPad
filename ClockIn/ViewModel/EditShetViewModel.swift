//
//  EditShetViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/18/23.
//

import Foundation
import Combine
//TODO: CLEAN UP MESS
final class EditSheetViewModel: ObservableObject {
    
    private var dataManager: DataManager
    private var settingsStore: SettingsStore
    private var entry: Entry
    // should move to view?
    @Published var shouldDisplayFullDates: Bool = false
    
    //MARK: ENTRY PROPERTIES
    //TODO: REMOVE DID SET
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
    // this cant be get properties since they can be different from the start date&finish date diff
    @Published var workTimeInSeconds: Int
    @Published var overTimeInSeconds: Int
    //think about joining the overtime properties or making it less spaghetti
    var currentMaximumOvertime: TimeInterval
    var currentStandardWorkTime: TimeInterval
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
    
    //MARK: GET PROPERTIES USED TO DRAW VIEWS <- MIGHT WANT TO MOVE TO VIEW
    var totalTimeInSeconds: TimeInterval {
        TimeInterval(workTimeInSeconds + overTimeInSeconds)
    }
    var workTimeFraction: CGFloat {
        CGFloat(workTimeInSeconds) / CGFloat(entry.standardWorktimeInSeconds)
    }
    var overTimeFraction: CGFloat {
        CGFloat(overTimeInSeconds) / CGFloat(entry.maximumOvertimeAllowedInSeconds)
    }
    
    init(dataManager: DataManager,  settingsStore: SettingsStore, entry: Entry) {
        self.dataManager = dataManager
        self.settingsStore = settingsStore
        self.entry = entry
        
        self.startDate = entry.startDate
        self.finishDate = entry.finishDate
        self.workTimeInSeconds = entry.workTimeInSeconds
        self.overTimeInSeconds = entry.overTimeInSeconds
        self.currentMaximumOvertime = TimeInterval(entry.maximumOvertimeAllowedInSeconds)
        self.currentStandardWorkTime = TimeInterval(entry.standardWorktimeInSeconds)
        self.grossPayPerMonth = String(entry.grossPayPerMonth)
        if let _ = entry.calculatedNetPay {
            self.calculateNetPay = true
        } else {
            self.calculateNetPay = false
        }
    }
    
    // calculating time intervals
    private func calculateTime() {
        let timeInterval = Calendar.current.dateComponents([.second], from: startDate, to: finishDate)
        if let seconds = timeInterval.second {
            if seconds <= entry.standardWorktimeInSeconds {
                workTimeInSeconds = seconds
                overTimeInSeconds = 0
            } else {
                workTimeInSeconds = entry.standardWorktimeInSeconds
                overTimeInSeconds = seconds - entry.standardWorktimeInSeconds
            }
        }
    }
    
    
    func saveEntry() {
        //TODO: ADD SAVING ADDITIONAL OVERRIDE PROPERTIES
        entry.startDate = startDate
        entry.finishDate = finishDate
        entry.workTimeInSeconds = workTimeInSeconds
        entry.overTimeInSeconds = overTimeInSeconds
        
        
        dataManager.updateAndSave(entry: entry)
        
    }
    
}

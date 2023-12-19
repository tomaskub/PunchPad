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
    //MARK: GET PROPERTIES USED TO DRAW VIEWS <- MIGHT WANT TO MOVE TO VIEW
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
        //assign values to draft properties
        self.startDate = entry.startDate
        self.finishDate = entry.finishDate
        self.workTimeInSeconds = TimeInterval(entry.workTimeInSeconds)
        self.overTimeInSeconds = TimeInterval(entry.overTimeInSeconds)
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
        //TODO: ADD SAVING ADDITIONAL OVERRIDE PROPERTIES
        entry.startDate = startDate
        entry.finishDate = finishDate
        entry.workTimeInSeconds = Int(workTimeInSeconds)
        entry.overTimeInSeconds = Int(overTimeInSeconds)
        
        
        dataManager.updateAndSave(entry: entry)
        
    }
    
}

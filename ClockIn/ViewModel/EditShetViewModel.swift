//
//  EditShetViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/18/23.
//

import Foundation

class EditSheetViewModel: ObservableObject {
    
    private var dataManager: DataManager
    private var entry: Entry
    private var workTimeAllowed: Int
    
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
    
    @Published var workTimeInSeconds: Int {
        didSet {
            workTimeString = generateHoursString(value: workTimeInSeconds)
        }
    }
    
    
    @Published var overTimeInSeconds: Int {
        didSet {
            overTimerString = generateHoursString(value: overTimeInSeconds)
        }
    }
    
    @Published var workTimeString: String
    @Published var overTimerString: String
    
    init(dataManager: DataManager = DataManager.shared, entry: Entry, overrideUserDefaults: Bool = false) {
        self.dataManager = dataManager
        self.entry = entry
        
        self.startDate = entry.startDate
        self.finishDate = entry.finishDate
        self.workTimeInSeconds = entry.workTimeInSeconds
        self.overTimeInSeconds = entry.overTimeInSeconds
        
        self.workTimeString = String()
        self.overTimerString = String()
        
        if overrideUserDefaults {
            self.workTimeAllowed = UserDefaults.standard.integer(forKey: K.UserDefaultsKeys.workTimeInSeconds)
        } else {
            self.workTimeAllowed = 8 * 3600
        }
        
        self.workTimeString = generateHoursString(value: workTimeInSeconds)
        self.overTimerString = generateHoursString(value: overTimeInSeconds)
        
        
    }
    
    func calculateTime() {
        let timeInterval = Calendar.current.dateComponents([.second], from: startDate, to: finishDate)
        if let seconds = timeInterval.second {
            if seconds < workTimeAllowed {
                workTimeInSeconds = seconds
            } else {
                workTimeInSeconds = workTimeAllowed
                overTimeInSeconds = seconds - workTimeAllowed
            }
        }
    }
    
    func generateHoursString(value: Int) -> String {
        let resultValue: Double = Double(value) / 3600
        return String(format: "%.2f", resultValue)
    }
    
    func saveEntry() {
        entry.startDate = startDate
        entry.finishDate = finishDate
        entry.workTimeInSeconds = workTimeInSeconds
        entry.overTimeInSeconds = overTimeInSeconds
        dataManager.updateAndSave(entry: entry)
        
    }
    
}

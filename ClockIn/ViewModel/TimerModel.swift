//
//  TimerModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI

class TimerModel: NSObject, ObservableObject {
    
    // Timer countdown total values pulled from user defaults
    @AppStorage(K.UserDefaultsKeys.workTimeInSeconds) var timerTotalSeconds: Int = 28800
    @AppStorage(K.UserDefaultsKeys.maximumOverTimeAllowedInSeconds) var overtimeTotalSeconds: Int = 18000
    
    //MARK: DATA MANAGING PROPERTIES
    private var dataManager: DataManager
    private var startDate: Date?
    private var finishDate: Date?
    
    //MARK: TIMER PROPERTIES - PUBLISHED
    //Published progress properties for UI
    @Published var progress: CGFloat = 0.0
    @Published var overtimeProgress: CGFloat = 0.0
    //Value for display
    @Published var timerStringValue: String = "00:00"
    
    @Published var secondProgress: CGFloat = 0.0
    @Published var minuteProgress: CGFloat = 0.0
    
    //Timer state properties
    @Published var isStarted: Bool = false
    @Published var isRunning: Bool = false
    @Published var progressAfterFinish: Bool = true
    
    //MARK: COUNTDOWN TIMER PROPERTIES - PRIVATE
    
    private var countSeconds: Int = 0
    private var currentHours: Int {
        return countSeconds/3600
    }
    private var currentMinutes: Int {
        return (countSeconds % 3600) / 60
    }
    private var currentSeconds: Int {
        return (countSeconds % 60)
    }
    //MARK: OVERTIME TIME PROPERTIES - PRIVATE
    private var countOvertimeSeconds: Int  = 0
    private var overtimeHours: Int {
        return countOvertimeSeconds/3600
    }
    private var overtimeMinutes: Int {
        return (countOvertimeSeconds % 3600) / 60
    }
    private var overtimeSeconds: Int {
        return (countOvertimeSeconds % 60)
    }
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
        super.init()
        // initialize properties:
        countSeconds = timerTotalSeconds
        let hours = timerTotalSeconds / 3600
        let minutes = (timerTotalSeconds % 3600) / 60
        let seconds = timerTotalSeconds % 60
        let hoursComponent: String = hours < 10 ? "0\(hours)" : "\(hours)"
        let minutesComponent: String = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let secondsComponent: String = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        
        if hours > 0 {
            timerStringValue = "\(hoursComponent) : \(minutesComponent)"
        } else {
            timerStringValue = "\(minutesComponent) : \(secondsComponent)"
        }
    }
}
    

    //MARK: TIMER START & STOP FUNCTIONS
extension TimerModel {
    
    func startTimer()  {
        
        startDate = Date()
        
        countSeconds = timerTotalSeconds
        countOvertimeSeconds = 0
        
        progress = 0
        overtimeProgress = 0
        
        isStarted = true
        isRunning = true
    }
    
    func stopTimer() {
        isStarted = false
        isRunning = false
        finishDate = Date()
        saveEntry()
    }
    
    func resumeTimer() {
        isRunning = true
    }
    
    func pauseTimer() {
        isRunning = false
        checkForPermissionAndDispatch()
    }
}
   
    //MARK: TIMER UPDATE FUNCTIONS
extension TimerModel {
    
    func updateTimer() {
        if isStarted && isRunning {
            
            if countSeconds > 0 {
                
                countSeconds -= 1
                
                updateSecondProgress()
                updateMinuteProgres()
                
                withAnimation(.easeInOut) {
                    progress = 1 - CGFloat(countSeconds) / CGFloat(timerTotalSeconds)
                }
                
            } else if countSeconds == 0 && !progressAfterFinish {
                stopTimer()
            } else if countSeconds == 0 && progressAfterFinish {
                countOvertimeSeconds += 1
                print("\(countOvertimeSeconds)")
                print("\(overtimeTotalSeconds)")
                overtimeProgress = CGFloat(countOvertimeSeconds) / CGFloat(overtimeTotalSeconds)
                print("\(overtimeProgress)")
            }
            
            updateTimerStringValue()
        }
    }
    
    
    func updateSecondProgress() {
        withAnimation(.linear) {
            secondProgress = 1 - (CGFloat(currentSeconds) / CGFloat(60))
        }
    }
    
    func updateMinuteProgres() {
        withAnimation(.easeInOut) {
            minuteProgress = 1 - (CGFloat(currentMinutes) / CGFloat(60))
        }
    }
    
    func updateTimerStringValue() {
        if countSeconds > 0 {
            
            let hoursComponent: String = currentHours < 10 ? "0\(currentHours)" : "\(currentHours)"
            let minutesComponent: String = currentMinutes < 10 ? "0\(currentMinutes)" : "\(currentMinutes)"
            let secondsComponent: String = currentSeconds < 10 ? "0\(currentSeconds)" : "\(currentSeconds)"
            
            if currentHours > 0 {
                timerStringValue = "\(hoursComponent) : \(minutesComponent)"
            } else {
                timerStringValue = "\(minutesComponent) : \(secondsComponent)"
            }
        } else if countOvertimeSeconds == 0 && countSeconds == 0 {
            timerStringValue = "00:00"
        } else {
            
            let hoursComponent: String = overtimeHours < 10 ? "0\(overtimeHours)" : "\(overtimeHours)"
            let minutesComponent: String = overtimeMinutes < 10 ? "0\(overtimeMinutes)" : "\(overtimeMinutes)"
            let secondsComponent: String = overtimeSeconds < 10 ? "0\(overtimeSeconds)" : "\(overtimeSeconds)"
            
            if overtimeHours > 0 {
                timerStringValue = "\(hoursComponent) : \(minutesComponent)"
            } else {
                timerStringValue = "\(minutesComponent) : \(secondsComponent)"
            }
        }
    }
    
}

    //MARK: DATA OPERATIONS
extension TimerModel {
    func checkForEntry() -> Bool {
        guard let entry = dataManager.fetch(forDate: Date()) else { return false }
        return true
    }
    func saveEntry() {
        guard let startDate = startDate, let finishDate = finishDate else { return }
        
        let workTimeInSeconds = timerTotalSeconds - countSeconds
        let overTimeInSeconds = countOvertimeSeconds
        
        let entryToSave = Entry(startDate: startDate, finishDate: finishDate, workTimeInSec: workTimeInSeconds, overTimeInSec: overTimeInSeconds)
        
        dataManager.updateAndSave(entry: entryToSave)
    }
}

//MARK: NOTIFICATIONS
extension TimerModel {
    func checkForPermissionAndDispatch() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatch()
            default:
                return
            }
        }
    }
    func dispatch() {
        
        var content = UNMutableNotificationContent()
        content.title = K.Notification.title
        content.body = K.Notification.body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: K.Notification.identifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        
    }
}

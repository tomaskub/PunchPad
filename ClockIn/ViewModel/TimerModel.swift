//
//  TimerModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI

class TimerModel: NSObject, ObservableObject {
    
    //MARK: TIMER PROPERTIES - PUBLISHED
    
    //Progress properties
    @Published var progress: CGFloat = 0.0
    @Published var secondProgress: CGFloat = 0.0
    @Published var minuteProgress: CGFloat = 0.0
    @Published var overtimeProgress: CGFloat = 0.0
    //Value for display
    @Published var timerStringValue: String = "08:30"
    
    //Timer state properties
    @Published var isStarted: Bool = false
    @Published var isRunning: Bool = false
    @Published var progressAfterFinish: Bool = true
    
    //starting values stored for the user
    @Published var hours: Int = 0
    @Published var minutes: Int = 1
    @Published var seconds: Int = 0
    
    
    //MARK: COUNTDOWN TIMER PROPERTIES - PRIVATE
    
    private var totalSeconds: Int = 0
    private var currentHours: Int {
        return totalSeconds/3600
    }
    private var currentMinutes: Int {
        return (totalSeconds % 3600) / 60
    }
    private var currentSeconds: Int {
        return (totalSeconds % 60)
    }
    //MARK: OVERTIME TIME PROPERTIES - PRIVATE
    private var overtimeTotalSeconds: Int  = 0
    private var overtimeHours: Int {
        return overtimeTotalSeconds/3600
    }
    private var overtimeMinutes: Int {
        return (overtimeTotalSeconds % 3600) / 60
    }
    private var overtimeSeconds: Int {
        return (overtimeTotalSeconds % 60)
    }
    override init() {
        super.init()
        let hoursComponent: String = hours < 10 ? "0\(hours)" : "\(hours)"
        let minutesComponent: String = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let secondsComponent: String = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        
        if currentHours > 0 {
            timerStringValue = "\(hoursComponent) : \(minutesComponent)"
        } else {
            timerStringValue = "\(minutesComponent) : \(secondsComponent)"
        }
    }
}
    

    //MARK: TIMER START & STOP FUNCTIONS
extension TimerModel {
    
    func startTimer()  {
        totalSeconds = 0
        progress = 0
        isStarted = true
        isRunning = true
        //This will have to be calculated somewhere else
        totalSeconds = (hours * 3600) + (minutes * 60) + seconds
    }
    
    func stopTimer() {
        isStarted = false
        isRunning = false
    }
    
    func resumeTimer() {
        isRunning = true
    }
    
    func pauseTimer() {
        isRunning = false
    }
}
   
    //MARK: TIMER UPDATE FUNCTIONS
extension TimerModel {
    
    func updateTimer() {
        if isStarted && isRunning {
            
            if totalSeconds > 0 {
                
                totalSeconds -= 1
                
                updateSecondProgress()
                updateMinuteProgres()
                
                withAnimation(.easeInOut) {
                    progress = 1 - CGFloat(totalSeconds) / CGFloat((hours * 3600) + (minutes * 60) + seconds)
                }
                
            } else if totalSeconds == 0 && !progressAfterFinish {
                stopTimer()
            } else if totalSeconds == 0 && progressAfterFinish {
                overtimeTotalSeconds += 1
                overtimeProgress = CGFloat(overtimeTotalSeconds % 60) / 60
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
        if totalSeconds > 0 {
            
            let hoursComponent: String = currentHours < 10 ? "0\(currentHours)" : "\(currentHours)"
            let minutesComponent: String = currentMinutes < 10 ? "0\(currentMinutes)" : "\(currentMinutes)"
            let secondsComponent: String = currentSeconds < 10 ? "0\(currentSeconds)" : "\(currentSeconds)"
            
            if currentHours > 0 {
                timerStringValue = "\(hoursComponent) : \(minutesComponent)"
            } else {
                timerStringValue = "\(minutesComponent) : \(secondsComponent)"
            }
        } else if overtimeTotalSeconds == 0 && totalSeconds == 0 {
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


//
//  TimerModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI

class TimerModel: NSObject, ObservableObject {
    //MARK: TIMER PROPERTIES
    
    @Published var progress: CGFloat = 0.5
    
    @Published var secondProgress: CGFloat = 0.0
    @Published var minuteProgress: CGFloat = 0.0
    
    @Published var timerStringValue: String = "00:00"
    @Published var isStarted: Bool = false
    @Published var addNewTimer: Bool = false
    
    @Published var hours: Int = 1
    @Published var minutes: Int = 10
    @Published var seconds: Int = 0
    
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
    
    func startTimer()  {
        isStarted = true
        progress = 0
        totalSeconds = (hours * 3600) + (minutes * 60) + seconds
        
    }
    
    func stopTimer() {
        hours = 0
        minutes = 0
        seconds = 0
        totalSeconds = 0
        progress = 0
        isStarted = false
    }
    
    func updateTimer() {
        if isStarted {
            if totalSeconds >= 0 {
            
                totalSeconds -= 1
                
                updateSecondProgress()
                updateMinuteProgres()
                
                withAnimation(.easeInOut) {
                    progress = 1 - CGFloat(totalSeconds) / CGFloat((hours * 3600) + (minutes * 60) + seconds)
                }
            
            } else if totalSeconds < 0 {
                stopTimer()
//                startTimer()
            }
        }
        updateTimerStringValue()
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
        let hoursComponent: String = currentHours < 10 ? "0\(currentHours)" : "\(currentHours)"
        let minutesComponent: String = currentMinutes < 10 ? "0\(currentMinutes)" : "\(currentMinutes)"
        let secondsComponent: String = currentSeconds < 10 ? "0\(currentSeconds)" : "\(currentSeconds)"
        
        if currentHours > 0 {
            timerStringValue = "\(hoursComponent) : \(minutesComponent)"
        } else {
            timerStringValue = "\(minutesComponent) : \(secondsComponent)"
        }
    }
}


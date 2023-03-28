//
//  TimerModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI

class TimerModel: NSObject, ObservableObject {
    //MARK: TIMER PROPERTIES
    @Published var progress: CGFloat = 0.6
    @Published var timerStringValue: String = "00:00"
    @Published var isStarted: Bool = false
    @Published var addNewTimer: Bool = false
    
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 60
    
    private var totalSeconds: Int = 0
    
    
    func startTimer()  {
        isStarted = true
        progress = 0
        totalSeconds = seconds
        
    }
    
    func stopTimer() {
        totalSeconds = 0
        progress = 0
        isStarted = false
    }
    
    func updateTimer() {
        if isStarted {
            if seconds > 0 {
                seconds -= 1
                progress = CGFloat(seconds) / CGFloat(totalSeconds)
                
            } else if seconds == 0 {
                stopTimer()
            }
        }
    }
}


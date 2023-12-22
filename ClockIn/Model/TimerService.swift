//
//  TimerService.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 22/12/2023.
//

import Foundation
import SwiftUI

class TimerService: ObservableObject {
    private enum TimerServiceState {
        case running, paused, stopped
    }
    private var timerProvider: Timer.Type
    private var timer: Timer?
    private let timerLimit: TimeInterval
    private let timerSecondLimit: TimeInterval
    private let progressAfterFinish: Bool
    private var serviceState: TimerServiceState = .stopped
    //Published progress properties for UI
    //Value for display, maybe these can be get properties
    @Published var progressToFirstLimit: CGFloat = 0.0
    @Published var progressToSecondLimit: CGFloat = 0.0

    //Timer state properties
    @Published var isStarted: Bool = false
    @Published var isRunning: Bool = false
    
    //MARK: COUNTDOWN TIMER PROPERTIES - PRIVATE
    // this is set at the begining to the limit and the counted down
    private var firstCounter: TimeInterval = 0
    //MARK: OVERTIME TIME PROPERTIES - PRIVATE
    // this is set at the begining to 0 and then added to
    private var secondCounter: TimeInterval  = 0
    
    init(timerProvider: Timer.Type, timerLimit: TimeInterval, timerSecondLimit: TimeInterval, progressAfterLimit: Bool) {
        self.timerLimit = timerLimit
        self.timerSecondLimit = timerSecondLimit
        self.timerProvider = timerProvider
        self.progressAfterFinish = progressAfterLimit
    }
    
    // start & stop
    func startTimer()  {
        if serviceState == .stopped {
            firstCounter = timerLimit
            secondCounter = 0
            
            progressToFirstLimit = 0
            progressToSecondLimit = 0
            // this still does not work in the background
            timer = timerProvider.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
                guard let self else { return }
                self.updateTimer()
            })
            isStarted = true
            isRunning = true
            serviceState = .running
        }
        if serviceState == .paused {
            serviceState = .running
        }
    }
    
    func stopTimer() {
        if let timer = timer {
            timer.invalidate()
        }
        isStarted = false
        isRunning = false
        serviceState = .stopped
    }
    
    func pauseTimer() {
        serviceState = .paused
    }
    // timer updates
    /**
     Updates the timer countdown value
     - Parameter subtrahend: The value to be substracted from the countdown (default is 1)
     */
    func updateTimer(subtract subtrahend: TimeInterval = 1) {
        if isStarted && isRunning {
            
            //This is the situation when the timer is still in current state after the update, including 0
            if firstCounter >= subtrahend {
                firstCounter -= subtrahend
                withAnimation(.easeInOut) {
                    progressToFirstLimit = 1 - CGFloat(firstCounter) / CGFloat(timerLimit)
                }
                
                return
            }
            //this is the situation when timer value moves it into overtime
            if firstCounter < subtrahend {
                if progressAfterFinish {
                    firstCounter = 0
                    secondCounter += subtrahend - firstCounter
                    //update the progress rings
                    withAnimation(.easeInOut) {
                        progressToFirstLimit = 1 - CGFloat(firstCounter) / CGFloat(timerLimit)
                        progressToSecondLimit = CGFloat(secondCounter) / CGFloat(timerSecondLimit)
                    }
                    
                } else {
                    firstCounter = 0
                    withAnimation(.easeInOut) {
                        progressToFirstLimit = 1 - CGFloat(firstCounter) / CGFloat(timerLimit)
                    }
                    
                    stopTimer()
                }
            }
        }
    }
}

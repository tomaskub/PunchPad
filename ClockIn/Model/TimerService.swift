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
    
    //Published progress properties for UI
    @Published var progressToFirstLimit: CGFloat = 0.0
    @Published var progressToSecondLimit: CGFloat = 0.0

    //Timer state properties
    @Published var isStarted: Bool = false
    @Published var isRunning: Bool = false
    private var serviceState: TimerServiceState = .stopped
    
    private(set) var firstCounter: TimeInterval = 0
    private(set) var secondCounter: TimeInterval  = 0
    
    init(timerProvider: Timer.Type, timerLimit: TimeInterval, timerSecondLimit: TimeInterval, progressAfterLimit: Bool) {
        self.timerLimit = timerLimit
        self.timerSecondLimit = timerSecondLimit
        self.timerProvider = timerProvider
        self.progressAfterFinish = progressAfterLimit
    }
    
    // start & stop
    func startTimer()  {
        if serviceState == .stopped {
            firstCounter = 0
            secondCounter = 0
            
            progressToFirstLimit = 0
            progressToSecondLimit = 0
            // this still does not work in the background
            timer = timerProvider.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
                guard let self else { return }
                self.updateTimer(byAdding: 1)
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
    
    func updateTimer(byAdding addValue: TimeInterval = 1) {
        guard self.serviceState == .running else { return }
        firstCounter += addValue
        if firstCounter >= timerLimit {
            secondCounter = firstCounter - timerLimit
        }
        withAnimation(.easeInOut) {
            updateProgressCounters()
        }
    }
    
    private func updateProgressCounters() {
        progressToFirstLimit = CGFloat(firstCounter / timerLimit)
        progressToSecondLimit = CGFloat(secondCounter / timerSecondLimit)
    }
}

//
//  TimerService.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 22/12/2023.
//

import Foundation
import SwiftUI

class TimerService: ObservableObject {
    enum TimerServiceState {
        case running, paused, notStarted, finished
    }
    enum TimerServiceEvent {
        case start, stop, pause, resumeWith(TimeInterval?)
    }
    
    private let timerProvider: Timer.Type
    private var timer: Timer?
    private let timerLimit: TimeInterval
    
    //Published progress properties for UI
    @Published var progress: CGFloat = 0.0
    @Published private(set) var serviceState: TimerServiceState = .notStarted
    @Published private(set) var counter: TimeInterval = 0
    var remainingTime: TimeInterval {
        timerLimit - counter
    }
    
    init(timerProvider: Timer.Type, timerLimit: TimeInterval) {
        self.timerLimit = timerLimit
        self.timerProvider = timerProvider
    }
    
    func send(event: TimerServiceEvent) {
        switch event {
        case .start:
            if serviceState == .notStarted {
                self.startTimer()
            } else if serviceState == .paused {
                serviceState = .running
            }
            
        case .pause:
            if serviceState == .running {
                serviceState = .paused
            } // else do nothing
            
        case .stop:
            if !(serviceState == .notStarted) {
                if let timer = timer {
                    timer.invalidate()
                }
                serviceState = .finished
            }
        case let .resumeWith(timePassed):
            if serviceState == .paused || serviceState == .running {
                self.serviceState = .running
                if let timePassed {
                    self.updateTimer(byAdding: timePassed)
                }
            }
        }
    }
    
    private func startTimer()  {
        counter = 0
        progress = 0
        serviceState = .running
        timer = timerProvider.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            self.updateTimer()
        })
    }
    
    /// Update the timer counter if it is running by a secified value
    /// - Parameter addValue: value to add to the counter, default is 1
    /// If the value added is larger than remaining time, it will be reduced to the remaining time left on timer. When reaching the timer limit, service state will be changed to `.finished`
    private func updateTimer(byAdding addValue: TimeInterval = 1) {
        guard self.serviceState == .running else { return }
        counter += addValue < remainingTime ? addValue : remainingTime
        withAnimation(.easeInOut) {
            updateProgressCounter()
        }
        if counter >= timerLimit {
            self.serviceState = .finished
        }
    }
    
    private func updateProgressCounter() {
        progress = CGFloat(counter / timerLimit)
    }
}

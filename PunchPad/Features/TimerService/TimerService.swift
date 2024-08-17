//
//  TimerService.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 22/12/2023.
//

import Foundation
import SwiftUI

final class TimerService: ObservableObject {
    private let timerProvider: Timer.Type
    private var timer: Timer?
    private let timerLimit: TimeInterval
    @Published private(set) var progress: CGFloat = 0.0
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
            }
            
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
    #warning("#1 - MAKE SURE IT WORK WITH UNIT TESTS")
    fileprivate func setTimerService(counter value: TimeInterval) {
        guard value <= timerLimit else {
            preconditionFailure("Attempted to set value larger than timer limit, this should not happen")
        }
        counter = value
        updateProgressCounter()
    }
    fileprivate func setTimerService(state: TimerServiceState) {
        serviceState = state
    }
    
    fileprivate func attachTimer() {
        timer = timerProvider.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            self.updateTimer()
        })
    }
}

extension TimerManager {
    func setInitialState(ofTimerService service: TimerService, toCounter value: TimeInterval, toState state: TimerServiceState) {
        service.setTimerService(counter: value)
        service.setTimerService(state: state)
        if state == .running || state == .paused {
            service.attachTimer()
        }
    }
}

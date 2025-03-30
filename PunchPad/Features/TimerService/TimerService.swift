//
//  TimerService.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 22/12/2023.
//

import Foundation
import SwiftUI
import OSLog

final class TimerService: ObservableObject {
    private let timerProvider: Timer.Type
    private var timer: Timer?
    private let timerLimit: TimeInterval
    private let logger = Logger.timerService
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
    
    // swiftlint:disable:next cyclomatic_complexity
    func send(event: TimerServiceEvent) {
        logger.debug("Recieved event \(event.debugDescription)")
        switch event {
        case .start:
            if serviceState == .notStarted {
                self.startTimer()
            } else if serviceState == .paused {
                serviceState = .running
            }
            
        case .pause:
            if serviceState == .running {
                logger.debug("Pausing timer")
                serviceState = .paused
            }
            
        case .stop:
            if !(serviceState == .notStarted) {
                logger.debug("Finishing timer")
                if let timer = timer {
                    timer.invalidate()
                }
                serviceState = .finished
            }
        case let .resumeWith(timePassed):
            if serviceState == .paused || serviceState == .running {
                logger.debug("Reasuming timer")
                self.serviceState = .running
                if let timePassed {
                    logger.debug("Updating timer with time passed: \(timePassed)")
                    self.updateTimer(byAdding: timePassed)
                }
            }
        }
    }
    
    private func startTimer() {
        logger.debug("startTimer called")
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
        logger.debug("updateProgressCounter called")
        progress = CGFloat(counter / timerLimit)
    }
    
    fileprivate func setTimerService(counter value: TimeInterval) {
        logger.debug("setTimerService called with value: \(value)")
        guard value <= timerLimit else {
            preconditionFailure("Attempted to set value larger than timer limit, this should not happen")
        }
        counter = value
        updateProgressCounter()
    }
    fileprivate func setTimerService(state: TimerServiceState) {
        logger.debug("setTimerService called with state: \(state.debugDescription)")
        serviceState = state
    }
    
    fileprivate func attachTimer() {
        logger.debug("attachTimer called")
        timer = timerProvider.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            self.updateTimer()
        })
    }
}

extension TimerManager {
    func setInitialState(ofTimerService service: TimerService,
                         toCounter value: TimeInterval,
                         toState state: TimerServiceState) {
        service.setTimerService(counter: value)
        service.setTimerService(state: state)
        if state == .running || state == .paused {
            service.attachTimer()
        }
    }
}

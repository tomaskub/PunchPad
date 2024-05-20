//
//  TimerManager.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 16/05/2024.
//

import Foundation
import Combine

class TimerManager: ObservableObject {
    private let timerProvider: Timer.Type
    private let configuration: TimerManagerConfiguration
    private var timerCancellables = Set<AnyCancellable>()
    var workTimerService: TimerService
    var overtimeTimerService: TimerService?
    @Published var state: TimerServiceState = .notStarted
    var timerDidFinish: PassthroughSubject<Date, Never> = .init()
    
    init(timerProvider: Timer.Type = Timer.self, with configuration: TimerManagerConfiguration) {
        self.timerProvider = timerProvider
        self.configuration = configuration
        self.workTimerService = .init(timerProvider: timerProvider, 
                                      timerLimit: configuration.workTimeInSeconds)
        if configuration.isLoggingOvertime,
            let limit = configuration.overtimeInSeconds {
            self.overtimeTimerService = .init(timerProvider: timerProvider, 
                                              timerLimit: limit)
        }
        setUpSubscriptions()
    }

    private func setUpSubscriptions() {
        // clear timer cancellables from old references
        timerCancellables.removeAll()
        
        workTimerService.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }.store(in: &timerCancellables)
    
        overtimeTimerService?.objectWillChange.sink(receiveValue: { _ in
            self.objectWillChange.send()
        }).store(in: &timerCancellables)
        
        if let overtimeTimerService = self.overtimeTimerService {
            
            self.workTimerService.$serviceState.filter { state in
                state == .finished
            }.sink { [weak self] _ in
                self?.overtimeTimerService?.send(event: .start)
            }.store(in: &timerCancellables)
            
            overtimeTimerService.$serviceState.filter { state in
                state == .finished
            }.sink { [weak self] _ in
                guard let self else { return }
                self.state = .finished
                self.timerDidFinish.send(Date())
            }.store(in: &timerCancellables)
            
        } else {
            self.workTimerService.$serviceState.filter { state in
                return state == .finished
            }.sink { [weak self] _ in
                guard let self else { return }
                self.state = .finished
                self.timerDidFinish.send(Date())
            }.store(in: &timerCancellables)
        }
    }
    
    func startTimerService() {
        guard state != .running else { return }
        if state == .finished {
            workTimerService = .init(
                timerProvider: timerProvider,
                timerLimit: configuration.workTimeInSeconds
            )
            if configuration.isLoggingOvertime, let limit = configuration.overtimeInSeconds {
                overtimeTimerService = .init(
                    timerProvider: timerProvider,
                    timerLimit: limit
                )
            }
            setUpSubscriptions()
        }
        self.state = .running
        workTimerService.send(event: .start)
    }
    
    func pauseTimerService() {
        guard state != .paused else { return }
        self.state = .paused
        workTimerService.send(event: .pause)
        overtimeTimerService?.send(event: .pause)
    }
    
    func resumeTimerService() {
        guard state != .running else { return }
        self.state = .running
        workTimerService.send(event: .resumeWith(nil))
        overtimeTimerService?.send(event: .resumeWith(nil))
    }
    
    func stopTimerService() {
        guard state != .finished else { return }
        workTimerService.send(event: .stop)
        overtimeTimerService?.send(event: .stop)
    }
    
    func resumeFromBackground(_ appDidEnterBackgroundDate: Date) {
        let timePassedInBackground = DateInterval(start: appDidEnterBackgroundDate, end: Date()).duration
        
        guard let overtimeTimerService else {
            if workTimerService.serviceState == .running {
                if timePassedInBackground < workTimerService.remainingTime {
                    workTimerService.send(event: .resumeWith(timePassedInBackground))
                } else {
                    timerCancellables.removeAll()
                    self.timerDidFinish.send(appDidEnterBackgroundDate.addingTimeInterval(workTimerService.remainingTime))
                    workTimerService.send(event: .resumeWith(timePassedInBackground))
                }
            }
            return
        }
        if workTimerService.serviceState == .running {
            if workTimerService.remainingTime < timePassedInBackground {
                let worktimePassedInBackground = workTimerService.remainingTime
                let overtimePassedInBackground = timePassedInBackground - worktimePassedInBackground
                workTimerService.send(event: .resumeWith(worktimePassedInBackground))
                overtimeTimerService.send(event: .start)
                if overtimePassedInBackground < overtimeTimerService.remainingTime {
                    overtimeTimerService.send(event: .resumeWith(overtimePassedInBackground))
                } else {
                    // To avoid additional timerDidFinish value sent with timer events
                    timerCancellables.removeAll()
                    let remainingTime = overtimeTimerService.remainingTime
                    overtimeTimerService.send(event: .resumeWith(remainingTime))
                    let finishDate = appDidEnterBackgroundDate.addingTimeInterval(worktimePassedInBackground + overtimeTimerService.counter)
                    self.timerDidFinish.send(finishDate)
                }
            } else {
                workTimerService.send(event: .resumeWith(timePassedInBackground))
            }
        } else if overtimeTimerService.serviceState == .running {
            if overtimeTimerService.remainingTime < timePassedInBackground {
                timerCancellables.removeAll()
                let remainingOvertime = overtimeTimerService.remainingTime
                overtimeTimerService.send(event: .resumeWith(remainingOvertime))
                let finishDate = appDidEnterBackgroundDate.addingTimeInterval(remainingOvertime)
                self.timerDidFinish.send(finishDate)
            } else {
                overtimeTimerService.send(event: .resumeWith(timePassedInBackground))
            }
        }
    }
}

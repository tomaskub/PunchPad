//
//  TimerModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI
import Combine

class HomeViewModel: NSObject, ObservableObject {
    private var dataManager: DataManager
    private var settingsStore: SettingsStore
    private var payManager: PayManager
    private var notificationService: NotificationService
    private var startDate: Date?
    private var finishDate: Date?
    private var appDidEnterBackgroundDate: Date?
    private var subscriptions = Set<AnyCancellable>()
    private var timerProvider: Timer.Type = Timer.self
    private var workTimerService: TimerService
    private var overtimeTimerService: TimerService?
    @Published var state: TimerService.TimerServiceState = .notStarted
    
    @Published var notificationText: String = "Workday finished!"
    @Published var isPresentingNotification: Bool = true
    
    var timerDisplayValue: TimeInterval {
        if let overtimeTimerService = overtimeTimerService {
            if overtimeTimerService.progress > 0 {
                return overtimeTimerService.counter
            } else {
                return workTimerService.counter
            }
        } else {
            return workTimerService.counter
        }
    }
    
    var normalProgress: CGFloat {
        return workTimerService.progress
    }
    
    var overtimeProgress: CGFloat {
        return overtimeTimerService?.progress ?? 0
    }
    
    init(dataManager: DataManager, settingsStore: SettingsStore, payManager: PayManager, notificationService: NotificationService, timerProvider: Timer.Type) {
        self.dataManager = dataManager
        self.settingsStore = settingsStore
        self.timerProvider = timerProvider
        self.payManager = payManager
        self.notificationService = notificationService
        self.workTimerService = .init(
            timerProvider: timerProvider,
            timerLimit: TimeInterval(settingsStore.workTimeInSeconds)
        )
        if self.settingsStore.isLoggingOvertime {
            self.overtimeTimerService = .init(
                timerProvider: timerProvider,
                timerLimit: TimeInterval(settingsStore.maximumOvertimeAllowedInSeconds))
        }
        super.init()
        
        setUpStoreSubscribers()
        setAppStateObservers()
        setUpTimerSubscribers()
    }
    
    private func setUpStoreSubscribers() {
        settingsStore.$isLoggingOvertime
            .filter { [weak self] _ in
                self?.state == .notStarted
            }.sink { [weak self] value in
                guard let self else { return }
                if value {
                    self.overtimeTimerService = .init(
                        timerProvider: timerProvider,
                        timerLimit: TimeInterval(settingsStore.maximumOvertimeAllowedInSeconds)
                    )
                } else {
                    self.overtimeTimerService = nil
                }
            }.store(in: &subscriptions)
        
        settingsStore.$workTimeInSeconds
            .filter { [weak self] _ in
                self?.state == .notStarted
            }.sink { [weak self] workTime in
                guard let self else { return }
                self.workTimerService = .init(
                        timerProvider: timerProvider,
                        timerLimit: TimeInterval(workTime)
                        )
            }.store(in: &subscriptions)
        
        settingsStore.$maximumOvertimeAllowedInSeconds
            .filter { [weak self] _ in
                self?.state == .notStarted && (self?.settingsStore.isLoggingOvertime ?? false)
            }.sink { [weak self] maximumOvertime in
                guard let self else { return }
                self.overtimeTimerService = .init(
                        timerProvider: timerProvider,
                        timerLimit: TimeInterval(maximumOvertime)
                        )
            }.store(in: &subscriptions)
    }
    
    private func setUpTimerSubscribers() {
        self.workTimerService.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }.store(in: &subscriptions)
        
        self.overtimeTimerService?.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }.store(in: &subscriptions)
        
        if let overtimeTimerService = self.overtimeTimerService {
            self.workTimerService.$serviceState.filter { state in
                state == .finished
            }.sink { [weak self] _ in
                self?.overtimeTimerService?.send(event: .start)
            }.store(in: &subscriptions)
            
            overtimeTimerService.$serviceState.filter { state in
                return state == .finished
            }.sink { [weak self] _ in
                guard let self else { return }
                self.state = .finished
                if let _ = self.finishDate {
                    self.saveEntry()
                } else {
                    self.finishDate = Date()
                    self.saveEntry()
                }
            }.store(in: &subscriptions)
        } else {
            self.workTimerService.$serviceState.filter { state in
                return state == .finished
            }.sink { [weak self] _ in
                guard let self else { return }
                self.state = .finished
                if let _ = self.finishDate {
                    self.saveEntry()
                } else {
                    self.finishDate = Date()
                    self.saveEntry()
                }
            }.store(in: &subscriptions)
        }
    }
}

//MARK: TIMER INTERFACE
extension HomeViewModel {
    
    func startTimerService() {
        guard state != .running else { return }
        //TODO: add clean up of old dates, subscribers and other data
        if state == .finished {
            workTimerService = .init(
                timerProvider: timerProvider,
                timerLimit: TimeInterval(settingsStore.workTimeInSeconds)
            )
            if settingsStore.isLoggingOvertime {
                overtimeTimerService = .init(
                    timerProvider: timerProvider,
                    timerLimit: TimeInterval(settingsStore.maximumOvertimeAllowedInSeconds)
                )
            }
            // this needs to deinitialize previous subscribers too
            setUpTimerSubscribers()
        }
        startDate = Date()
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
        finishDate = Date()
        workTimerService.send(event: .stop)
        overtimeTimerService?.send(event: .stop)
    }
}

//MARK: HANDLING BACKGROUND TIMER UPDATE FUNC
extension HomeViewModel {
    /// Set up combine subs to UI application background and foreground events
    private func setAppStateObservers() {
        NotificationCenter.default
            .publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.appDidEnterBackground()
            }.store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.appWillEnterForeground()
            }.store(in: &subscriptions)
    }
    
    /// Set appDidEnterBackgroundDate to now and set notifications for worktime and overtime timers finish
    private func appDidEnterBackground() {
        appDidEnterBackgroundDate = Date()
        scheduleTimerFinishNotifications()
    }
    
    /// Remove pending notifications for timers and update timers
    private func appWillEnterForeground() {
        if let appDidEnterBackgroundDate {
            resumeFromBackground(appDidEnterBackgroundDate)
        }
        notificationService.deschedulePendingNotifications()
    }
    
    func resumeFromBackground(_ appDidEnterBackgroundDate: Date) {
        let timePassedInBackground = DateInterval(start: appDidEnterBackgroundDate, end: Date()).duration
        // Handle update of timer when no overtime is allowed
        guard let overtimeTimerService else {
            if workTimerService.serviceState == .running {
                if timePassedInBackground < workTimerService.remainingTime {
                    workTimerService.send(event: .resumeWith(timePassedInBackground))
                } else {
                    self.finishDate = appDidEnterBackgroundDate.addingTimeInterval(workTimerService.remainingTime)
                    workTimerService.send(event: .resumeWith(timePassedInBackground))
                }
            }
            return
        }
        // Handle update of timer when there is overtime
        if workTimerService.serviceState == .running {
            if workTimerService.remainingTime < timePassedInBackground {
                let worktimePassedInBackground = workTimerService.remainingTime
                let overtimePassedInBackground = timePassedInBackground - worktimePassedInBackground
                workTimerService.send(event: .resumeWith(worktimePassedInBackground))
                //something is wrong - at this time the overtime timer service has timer limit of 0?
                overtimeTimerService.send(event: .start)
                if overtimePassedInBackground < overtimeTimerService.remainingTime {
                    overtimeTimerService.send(event: .resumeWith(overtimePassedInBackground))
                } else {
                    self.finishDate = appDidEnterBackgroundDate.addingTimeInterval(worktimePassedInBackground + overtimeTimerService.remainingTime)
                    // OVERTIME DID NOT REGISTER HERE
                    overtimeTimerService.send(event: .resumeWith(overtimeTimerService.remainingTime))
                }
            } else {
                workTimerService.send(event: .resumeWith(timePassedInBackground))
            }
        } else if overtimeTimerService.serviceState == .running {
            if overtimeTimerService.remainingTime < timePassedInBackground {
                let remainingOvertime = overtimeTimerService.remainingTime
                self.finishDate = appDidEnterBackgroundDate.addingTimeInterval(remainingOvertime)
                overtimeTimerService.send(event: .resumeWith(remainingOvertime))
            } else {
                overtimeTimerService.send(event: .resumeWith(timePassedInBackground))
            }
        }
        self.appDidEnterBackgroundDate = nil
    }
}

//MARK: DATA OPERATIONS
extension HomeViewModel {
    func saveEntry() {
        guard let startDate = startDate, let finishDate = finishDate else { return }
        let calculatedNetPay: Double? = {
            settingsStore.isCalculatingNetPay ? payManager.calculateNetPay(gross: Double(settingsStore.grossPayPerMonth)) : nil
        }()
        let entryToSave = Entry(startDate: startDate,
                                finishDate: finishDate,
                                workTimeInSec: Int(workTimerService.counter),
                                overTimeInSec: Int(overtimeTimerService?.counter ?? 0),
                                maximumOvertimeAllowedInSeconds: settingsStore.maximumOvertimeAllowedInSeconds,
                                standardWorktimeInSeconds: settingsStore.workTimeInSeconds,
                                grossPayPerMonth: settingsStore.grossPayPerMonth, 
                                calculatedNetPay: calculatedNetPay
        )
        dataManager.updateAndSave(entry: entryToSave)
    }
}

//MARK: NOTIFICATIONS
extension HomeViewModel {
    /// Schedule notifications for finish of overtime timer service and worktime timer service
    private func scheduleTimerFinishNotifications() {
        guard settingsStore.isSendingNotification else { return }
        if let overtimeTimerService {
            if workTimerService.serviceState == .running {
                notificationService.scheduleNotification(for: .workTime, in: workTimerService.remainingTime)
                notificationService.scheduleNotification(for: .overTime, in: workTimerService.remainingTime + overtimeTimerService.remainingTime)
            } else if overtimeTimerService.serviceState == .running {
                notificationService.scheduleNotification(for: .overTime, in: overtimeTimerService.remainingTime)
            }
        } else if workTimerService.serviceState == .running {
            notificationService.scheduleNotification(for: .workTime, in: workTimerService.remainingTime)
        }
    }
}

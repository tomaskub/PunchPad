//
//  TimerModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI
import Combine

class HomeViewModel: NSObject, ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    private var timerManagerCancellables = Set<AnyCancellable>()
    private var dataManager: any DataManaging
    private var settingsStore: SettingsStore
    private var payManager: PayManager
    private var notificationService: NotificationService
    private var timerManagerConfiguration: TimerManagerConfiguration
    private var timerManager: TimerManager
    private var timerStore: TimerStore = .init(defaults: .standard)
    private var timerProvider: Timer.Type
    private var timersNotRunning: Bool { 
        self.state == .notStarted || self.state == .finished
    }
    private var startDate: Date?
    private var finishDate: Date?
    private var appDidEnterBackgroundDate: Date?
    private var currentTimerModel: TimerModel?
    var state: TimerServiceState {
        timerManager.state
    }
    var timerDisplayValue: TimeInterval {
        if let overtimeTimerService = timerManager.overtimeTimerService {
            if overtimeTimerService.progress > 0 {
                return overtimeTimerService.counter
            } else {
                return timerManager.workTimerService.counter
            }
        } else {
            return timerManager.workTimerService.counter
        }
    }
    var normalProgress: CGFloat {
        timerManager.workTimerService.progress
    }
    var overtimeProgress: CGFloat {
        timerManager.overtimeTimerService?.progress ?? 0
    }
    
    init(dataManager: any DataManaging, settingsStore: SettingsStore, payManager: PayManager, notificationService: NotificationService, timerProvider: Timer.Type = Timer.self) {
        self.dataManager = dataManager
        self.settingsStore = settingsStore
        self.timerProvider = timerProvider
        self.payManager = payManager
        self.notificationService = notificationService
        #warning("#3 - cover with unit test and make sure implementation works")
        // TODO: ALWAYS INIT FROM MODEL, IF NOT PRESENT, INIT WITHOUT MODEL, GET MODEL FROM STORE ON INIT
        self.timerManagerConfiguration = TimerManagerConfiguration(
            workTimeInSeconds: TimeInterval(settingsStore.workTimeInSeconds),
            isLoggingOvertime: settingsStore.isLoggingOvertime,
            overtimeInSeconds: TimeInterval(settingsStore.maximumOvertimeAllowedInSeconds)
        )
        self.timerManager = TimerManager(timerProvider: timerProvider,
                                         with: timerManagerConfiguration)
        super.init()
        
        setUpStoreSubscribers()
        setAppStateObservers()
        setUpTimerManagerSubscribers()
    }
    
    private func setUpStoreSubscribers() {
        settingsStore.$isLoggingOvertime
            .filter { [weak self] _ in
                self?.timersNotRunning ?? false
            }.sink { [weak self] value in
                guard let self else { return }
                if value {
                    let config = TimerManagerConfiguration(
                        workTimeInSeconds: TimeInterval(settingsStore.workTimeInSeconds),
                        isLoggingOvertime: value,
                        overtimeInSeconds: TimeInterval(settingsStore.maximumOvertimeAllowedInSeconds)
                    )
                    reloadTimerManager(with: config)
                } else {
                    let config = TimerManagerConfiguration(
                        workTimeInSeconds: TimeInterval(settingsStore.workTimeInSeconds),
                        isLoggingOvertime: false,
                        overtimeInSeconds: nil)
                    reloadTimerManager(with: config)
                }
            }.store(in: &subscriptions)
        
        settingsStore.$workTimeInSeconds
            .filter { [weak self] _ in
                self?.timersNotRunning ?? false
            }.sink { [weak self] workTime in
                guard let self else { return }
                let config = TimerManagerConfiguration(
                    workTimeInSeconds: TimeInterval(workTime),
                    isLoggingOvertime: settingsStore.isLoggingOvertime,
                    overtimeInSeconds: TimeInterval(settingsStore.maximumOvertimeAllowedInSeconds)
                )
                reloadTimerManager(with: config)
            }.store(in: &subscriptions)
        
        settingsStore.$maximumOvertimeAllowedInSeconds
            .filter { [weak self] _ in
                (self?.timersNotRunning ?? false) && (self?.settingsStore.isLoggingOvertime ?? false)
            }.sink { [weak self] maximumOvertime in
                guard let self else { return }
                let config = TimerManagerConfiguration(
                    workTimeInSeconds: TimeInterval(settingsStore.workTimeInSeconds),
                    isLoggingOvertime: settingsStore.isLoggingOvertime,
                    overtimeInSeconds: TimeInterval(maximumOvertime)
                )
                timerManager = .init(timerProvider: timerProvider, with: config)
            }.store(in: &subscriptions)
    }
    
    private func setUpTimerManagerSubscribers() {
        timerManagerCancellables.removeAll()
        
        self.timerManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &timerManagerCancellables)
        
        self.timerManager.timerDidFinish
            .sink { [weak self] date in
                self?.finishDate = date
                self?.saveEntry()
            }.store(in: &timerManagerCancellables)
    }
    
    private func reloadTimerManager(with config: TimerManagerConfiguration) {
        timerManager = .init(timerProvider: timerProvider, with: config)
        setUpTimerManagerSubscribers()
    }
}

//MARK: TIMER INTERFACE
extension HomeViewModel {
    func startTimerService() {
        guard state != .running else { return }
        timerManager.startTimerService()
        startDate = Date()
    }
    
    func pauseTimerService() {
        guard state != .paused else { return }
        timerManager.pauseTimerService()
    }
    
    func resumeTimerService() {
        guard state != .running else { return }
        timerManager.resumeTimerService()
    }
    
    func stopTimerService() {
        guard state != .finished else { return }
        timerManager.stopTimerService()
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
        NotificationCenter.default
            .publisher(for: UIApplication.willTerminateNotification)
            .sink { _ in
                print("App will terminate - should save timer configuration present in background")
            }.store(in: &subscriptions)
    }
    
    /// Set appDidEnterBackgroundDate to now and set notifications for worktime and overtime timers finish
    private func appDidEnterBackground() {
        let model = generateTimerModel()
        appDidEnterBackgroundDate = model.timeStamp
        currentTimerModel = model
        do {
            print("Attempting to save current timer model")
            try timerStore.save(model)
            print("Saved model successfully")
        } catch {
            print("Failed to save model on entering background \(error)")
        }
        scheduleTimerFinishNotifications()
    }
    
    /// Remove pending notifications for timers and update timers
    private func appWillEnterForeground() {
        if let appDidEnterBackgroundDate {
            timerManager.resumeFromBackground(appDidEnterBackgroundDate)
        }
        appDidEnterBackgroundDate = nil
        notificationService.deschedulePendingNotifications()
    }
}

//MARK: DATA OPERATIONS
extension HomeViewModel {
    func saveEntry() {
        guard let startDate = startDate, let finishDate = finishDate else { return }
        let calculatedNetPay: Double? = {
            settingsStore.isCalculatingNetPay ? payManager.calculateNetPay(gross: Double(settingsStore.grossPayPerMonth)) : nil
        }()
        let timeWorked = Int(timerManager.workTimerService.counter)
        let overtimeWorked = Int(timerManager.overtimeTimerService?.counter ?? 0)
        let entryToSave = Entry(startDate: startDate,
                                finishDate: finishDate,
                                workTimeInSec: timeWorked,
                                overTimeInSec: overtimeWorked,
                                maximumOvertimeAllowedInSeconds: settingsStore.maximumOvertimeAllowedInSeconds,
                                standardWorktimeInSeconds: settingsStore.workTimeInSeconds,
                                grossPayPerMonth: settingsStore.grossPayPerMonth, 
                                calculatedNetPay: calculatedNetPay
        )
        dataManager.updateAndSave(entry: entryToSave)
        self.startDate = nil
        self.finishDate = nil
    }
    
    func generateTimerModel() -> TimerModel {
           TimerModel(configuration: timerManagerConfiguration,
                                        workTimeCounter: timerManager.workTimerService.counter,
                                        overtimeCounter: timerManager.overtimeTimerService?.counter,
                                        workTimerState: timerManager.workTimerService.serviceState,
                                        overtimeTimerState: timerManager.overtimeTimerService?.serviceState,
                                        timeStamp: Date())
    }
}

//MARK: NOTIFICATIONS
extension HomeViewModel {
    /// Schedule notifications for finish of overtime timer service and worktime timer service
    private func scheduleTimerFinishNotifications() {
        guard settingsStore.isSendingNotification else { return }
        if let overtimeService = timerManager.overtimeTimerService {
            if timerManager.workTimerService.serviceState == .running {
                notificationService.scheduleNotification(for: .workTime, 
                                                         in: timerManager.workTimerService.remainingTime)
                let overtimeNotificationTimeInterval = timerManager.workTimerService.remainingTime + overtimeService.remainingTime
                notificationService.scheduleNotification(for: .overTime,
                                                         in: overtimeNotificationTimeInterval)
            } else if overtimeService.serviceState == .running {
                notificationService.scheduleNotification(for: .overTime, in: overtimeService.remainingTime)
            }
        } else if timerManager.workTimerService.serviceState == .running {
            notificationService.scheduleNotification(for: .workTime, in: timerManager.workTimerService.remainingTime)
        }
    }
}

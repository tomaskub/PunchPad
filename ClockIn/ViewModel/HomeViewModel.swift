//
//  TimerModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI
import Combine
//TODO: Resume from background does not work on second timer - move to VM
//TODO: fix bug when time in background is bigger than timer limit - first timer never emits finish - move to VM
//TODO: Remove bug when timer is not saving entry when not stopped with button - move to VM

class HomeViewModel: NSObject, ObservableObject {
    private var dataManager: DataManager
    private var settingsStore: SettingsStore
    private var payManager: PayManager
    private var startDate: Date?
    private var finishDate: Date?
    private var appDidEnterBackgroundDate: Date?
    private var subscriptions = Set<AnyCancellable>()
    private var timerProvider: Timer.Type = Timer.self
    private var workTimerService: TimerService
    private var overtimeTimerService: TimerService?
    @Published var state: TimerService.TimerServiceState = .notStarted
    
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
    
    init(dataManager: DataManager, settingsStore: SettingsStore, payManager: PayManager ,timerProvider: Timer.Type) {
        self.dataManager = dataManager
        self.settingsStore = settingsStore
        self.timerProvider = timerProvider
        self.payManager = payManager
        // register new timer service
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
        setAppStateObservers()
        setUpTimerSubscribers()
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
                self?.saveEntry()
            }.store(in: &subscriptions)
        } else {
            self.workTimerService.$serviceState.filter { state in
                return state == .finished
            }.sink { [weak self] _ in
                
                self?.saveEntry()
            }.store(in: &subscriptions)
        }
    }
}

//MARK: TIMER INTERFACE
extension HomeViewModel {
    // should start a new timer
    func startTimerService() {
        if workTimerService.serviceState == .finished {
            workTimerService = .init(
                timerProvider: timerProvider,
                timerLimit: TimeInterval(settingsStore.workTimeInSeconds)
            )
            setUpTimerSubscribers()
        }
        if workTimerService.serviceState == .notStarted {
            startDate = Date()
        }
        self.state = .running
        workTimerService.send(event: .start)
    }
    
    func pauseTimerService() {
        self.state = .paused
        workTimerService.send(event: .pause)
        overtimeTimerService?.send(event: .pause)
    }
    func resumeTimerService() {
        self.state = .running
        workTimerService.send(event: .resumeWith(nil))
        overtimeTimerService?.send(event: .resumeWith(nil))
    }
    func stopTimerService() {
        self.state = .notStarted
        finishDate = Date()
        workTimerService.send(event: .stop)
        overtimeTimerService?.send(event: .stop)
    }
    func resumeFromBackground(_ appDidEnterBackgroundDate: Date) {
        let timePassedInBackground = DateInterval(start: appDidEnterBackgroundDate, end: Date()).duration
        workTimerService.send(event: .resumeWith(timePassedInBackground))
    }
}

//MARK: HANDLING BACKGROUND TIMER UPDATE FUNC
extension HomeViewModel {
    
    private func setAppStateObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func appDidEnterBackground() {
        if workTimerService.serviceState == .running {
            appDidEnterBackgroundDate = Date()
            let timeToTimerFinish: TimeInterval? = {
                if workTimerService.serviceState == .running {
                    return workTimerService.remainingTime
                }
                return nil
            }()
            guard let timeToTimerFinish else { return }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeToTimerFinish , repeats: false)
            checkForPermissionAndDispatch(withTrigger: trigger)
        }
    }
    
    @objc private func appWillEnterForeground() {
        guard let appDidEnterBackgroundDate else { return }
        resumeFromBackground(appDidEnterBackgroundDate)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [K.Notification.identifier])
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
                                overTimeInSec: 0,
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
    
    func checkForPermissionAndDispatch(withTrigger trigger: UNNotificationTrigger? = nil) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatch(withTrigger: trigger)
            default:
                return
            }
        }
    }
    ///dispatch a local notification with standard title and body
    ///- Parameter trigger: a UNNotificationTrigger, set to nil for dispatching now
    func dispatch(withTrigger trigger: UNNotificationTrigger? = nil) {
        
        let content = UNMutableNotificationContent()
        content.title = K.Notification.title
        content.body = K.Notification.body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: K.Notification.identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
    }
}

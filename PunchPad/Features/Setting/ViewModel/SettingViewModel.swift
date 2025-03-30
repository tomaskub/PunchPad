//
//  SettingViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/3/23.
//

import Combine
import SwiftUI

final class SettingsViewModel: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    private var notificationService: NotificationService
    private var dataManager: any DataManaging
    private let secondsInHour = 3600
    private let secondsInMinute = 60
    @Published var settingsStore: SettingsStore
    @Published var timerHours: Int
    @Published var timerMinutes: Int
    @Published var overtimeHours: Int
    @Published var overtimeMinutes: Int
    @Published var grossPayPerMonth: Int
    @Published var shouldShowNotificationDeniedAlert: Bool = false
    
    init(dataManger: any DataManaging, notificationService: NotificationService, settingsStore: SettingsStore) {
        self.dataManager = dataManger
        self.notificationService = notificationService
        self.settingsStore = settingsStore
        self.timerHours = settingsStore.workTimeInSeconds / secondsInHour
        self.timerMinutes = (settingsStore.workTimeInSeconds % secondsInHour) / secondsInMinute
        self.overtimeHours = settingsStore.maximumOvertimeAllowedInSeconds / secondsInHour
        self.overtimeMinutes = (settingsStore.maximumOvertimeAllowedInSeconds % secondsInHour) / secondsInMinute
        self.grossPayPerMonth = settingsStore.grossPayPerMonth
        setSubscribers()
    }
    
    func deleteAllData() {
        dataManager.deleteAll()
    }
    
    func resetUserDefaults() {
        settingsStore.clearStore()
    }
    
    private func setSubscribers() {
        setSettingStoreSubscribers()
        setWorkTimeUISubscribers()
        setOvertimeUISubscribers()
        setGrossPayUISubscribers()
    }
    
    private func setSettingStoreSubscribers() {
        settingsStore.$workTimeInSeconds
            .receive(on: RunLoop.main)
            .filter { [weak self] value in
                guard let self else { return false }
                let isHourChange = value/self.secondsInHour != self.timerHours
                let isMinuteChange = (value % self.secondsInHour) / self.secondsInMinute != self.timerMinutes
                return isHourChange || isMinuteChange
            }
            .sink { [weak self] value in
                guard let self else { return }
                self.timerHours = value / secondsInHour
                self.timerMinutes = (value % secondsInHour) / secondsInMinute
            }.store(in: &subscriptions)
        
        settingsStore.$maximumOvertimeAllowedInSeconds
            .receive(on: RunLoop.main)
            .filter { [weak self] value in
                guard let self else { return false }
                let isHourChange = value/secondsInHour != self.overtimeHours
                let isMinuteChange = (value % secondsInHour) / secondsInMinute != self.overtimeMinutes
                return  isHourChange || isMinuteChange
            }
            .sink { [weak self] value in
                guard let self else { return }
                self.overtimeHours = value / secondsInHour
                self.overtimeMinutes = (value % secondsInHour) / secondsInMinute
            }.store(in: &subscriptions)
        
        settingsStore.$grossPayPerMonth
            .receive(on: RunLoop.main)
            .filter { [weak self] newGross in
                guard let self else { return false }
                return newGross != self.grossPayPerMonth
            }
            .sink { [weak self] newGross in
                guard let self else { return }
                self.grossPayPerMonth = newGross
            }.store(in: &subscriptions)
        
        settingsStore.$isSendingNotification
            .removeDuplicates()
            .filter { $0 }
            .sink { [weak self] value in
                self?.requestAuthorizationForNotifications()
            }.store(in: &subscriptions)
        
        $shouldShowNotificationDeniedAlert
            .dropFirst()
            .removeDuplicates()
            .filter { !$0 }
            .receive(on: RunLoop.main)
            .assign(to: &self.settingsStore.$isSendingNotification)
        
        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .filter { [weak self] _ in
                self?.settingsStore.isSendingNotification ?? false
            }
            .sink { [weak self] _ in
                self?.requestAuthorizationForNotifications()
            }.store(in: &subscriptions)
    }
    
    private func requestAuthorizationForNotifications() {
        self.notificationService.requestAuthorizationForNotifications { [weak self] result, error in
            DispatchQueue.main.async {
                self?.shouldShowNotificationDeniedAlert = !result
            }
        }
    }
    
    private func setGrossPayUISubscribers() {
        $grossPayPerMonth.sink { [weak self] value in
            guard let self else { return }
            self.settingsStore.grossPayPerMonth = value
        }.store(in: &subscriptions)
    }
    
    private func setWorkTimeUISubscribers() {
        $timerHours
            .removeDuplicates()
            .sink(receiveValue: { [weak self] hours in
                guard let self else { return }
                let newWorkTime = self.calculateTimeInSeconds(hours: hours, minutes: self.timerMinutes)
                if newWorkTime != self.settingsStore.workTimeInSeconds {
                    self.settingsStore.workTimeInSeconds = newWorkTime
                }
            }).store(in: &subscriptions)
        
        $timerMinutes
            .removeDuplicates()
            .sink(receiveValue: { [weak self] minutes in
                guard let self else { return }
                let newWorkTime = self.calculateTimeInSeconds(hours: self.timerHours, minutes: minutes)
                if newWorkTime != self.settingsStore.workTimeInSeconds {
                    self.settingsStore.workTimeInSeconds = newWorkTime
                }
            }).store(in: &subscriptions)
    }
    
    private func setOvertimeUISubscribers() {
        $overtimeHours
            .removeDuplicates()
            .sink(receiveValue: { [weak self] hours in
                guard let self else { return }
                let newOverTime = self.calculateTimeInSeconds(hours: hours, minutes: self.overtimeMinutes)
                if newOverTime != self.settingsStore.maximumOvertimeAllowedInSeconds {
                    self.settingsStore.maximumOvertimeAllowedInSeconds = newOverTime
                }
            }).store(in: &subscriptions)
        
        $overtimeMinutes
            .removeDuplicates()
            .sink(receiveValue: { [weak self] minutes in
                guard let self else { return }
                let newOverTime = self.calculateTimeInSeconds(hours: self.overtimeHours, minutes: minutes)
                if newOverTime != self.settingsStore.maximumOvertimeAllowedInSeconds {
                    self.settingsStore.maximumOvertimeAllowedInSeconds = newOverTime
                }
            }).store(in: &subscriptions)
    }
    
    private func calculateTimeInSeconds(hours: Int, minutes: Int) -> Int {
        hours * secondsInHour + minutes * secondsInMinute
    }
}

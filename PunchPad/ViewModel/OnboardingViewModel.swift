//
//  OnboardingViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/23/23.
//

import Foundation
import Combine
import UserNotifications

class OnboardingViewModel: ObservableObject {
    
    private var subscriptions = Set<AnyCancellable>()
    private var notificationService: NotificationService
    @Published var settingsStore: SettingsStore
    @Published var grossPayPerMonthText: Int
    @Published var hoursWorking: Int
    @Published var minutesWorking: Int
    @Published var hoursOvertime: Int
    @Published var minutesOvertime: Int
    @Published var authorizationDenied = false
    @Published var shouldShowNotificationDeniedAlert = false
    
    init(notificationService: NotificationService, settingsStore: SettingsStore) {
        self.notificationService = notificationService
        self.settingsStore = settingsStore
        self.hoursWorking = settingsStore.workTimeInSeconds / 3600
        self.minutesWorking = (settingsStore.workTimeInSeconds % 3600) / 60
        self.hoursOvertime = settingsStore.maximumOvertimeAllowedInSeconds / 3600
        self.minutesOvertime = (settingsStore.maximumOvertimeAllowedInSeconds % 3600) / 60
        self.grossPayPerMonthText = settingsStore.grossPayPerMonth
        setPublishers()
    }
    
    private func setPublishers() {
        $hoursWorking
            .removeDuplicates()
            .sink { [weak self] hours in
                guard let self else { return }
                self.settingsStore.workTimeInSeconds = self.calculateTimeInSeconds(hours: hours, minutes: self.minutesWorking)
            }.store(in: &subscriptions)
        
        $minutesWorking
            .removeDuplicates()
            .sink { [weak self] minutes in
                guard let self else { return }
                self.settingsStore.workTimeInSeconds = self.calculateTimeInSeconds(hours: self.hoursWorking, minutes: minutes)
            }.store(in: &subscriptions)
        
        $hoursOvertime
            .removeDuplicates()
            .sink { [weak self] hours in
                guard let self else { return }
                self.settingsStore.maximumOvertimeAllowedInSeconds = self.calculateTimeInSeconds(hours: hours, minutes: self.minutesOvertime)
            }.store(in: &subscriptions)
        
        $minutesOvertime
            .removeDuplicates()
            .sink { [weak self] minutes in
                guard let self else { return }
                self.settingsStore.maximumOvertimeAllowedInSeconds = self.calculateTimeInSeconds(hours: self.hoursOvertime, minutes: minutes)
            }.store(in: &subscriptions)
        
        $grossPayPerMonthText
            .removeDuplicates()
            .sink { [weak self] newValue in
                guard let self else { return }
                self.settingsStore.grossPayPerMonth = newValue
            }.store(in: &subscriptions)
        
        settingsStore.$isSendingNotification
            .filter { [weak self] value in
                guard let self else { return false }
                return value && !self.authorizationDenied
            }
            .sink { [weak self] value in
                self?.requestAuthorizationForNotifications()
            }.store(in: &subscriptions)
        
        settingsStore.$isSendingNotification
            .filter { [weak self] _ in
                guard let self else { return false }
                return self.authorizationDenied
            }.sink { [weak self] _ in
                guard let self else { return }
                self.shouldShowNotificationDeniedAlert = true
            }.store(in: &subscriptions)
        
        $shouldShowNotificationDeniedAlert
            .dropFirst()
            .removeDuplicates()
            .filter { value in
                !value
            }.sink { [weak self] _ in
                guard let self else { return }
                self.settingsStore.isSendingNotification = false
            }.store(in: &subscriptions)
            
    }
    
    private func calculateTimeInSeconds(hours: Int, minutes: Int) -> Int {
        return hours * 3600 + minutes * 60
    }
    
    func requestAuthorizationForNotifications() {
        notificationService.requestAuthorizationForNotifications { [weak self] result, error in
            DispatchQueue.main.async {
                self?.settingsStore.isSendingNotification = result
                self?.authorizationDenied = !result
            }
        }
    }
}

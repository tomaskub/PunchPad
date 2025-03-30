//
//  OnboardingViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/23/23.
//

import Foundation
import Combine
import UserNotifications
import OSLog

final class OnboardingViewModel: ObservableObject {
    private let secondsInHour = 3600
    private let secondsInMinute = 60
    private let logger = Logger.onboardingViewModel
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
        self.hoursWorking = settingsStore.workTimeInSeconds / secondsInHour
        self.minutesWorking = (settingsStore.workTimeInSeconds % secondsInHour) / secondsInMinute
        self.hoursOvertime = settingsStore.maximumOvertimeAllowedInSeconds / secondsInHour
        self.minutesOvertime = (settingsStore.maximumOvertimeAllowedInSeconds % secondsInHour) / secondsInMinute
        self.grossPayPerMonthText = settingsStore.grossPayPerMonth
        setPublishers()
    }
    
    func requestAuthorizationForNotifications() {
        logger.debug("requestAuthorizationForNotifications called")
        notificationService.requestAuthorizationForNotifications { [weak self] result, _ in
            DispatchQueue.main.async {
                self?.settingsStore.isSendingNotification = result
                self?.authorizationDenied = !result
            }
        }
    }
    
    private func setPublishers() {
        logger.debug("setPublishers called")
        
        setupWorkingTimePublishers()
        setupOvertimePublishers()
        setupNotificationSendingPublishers()
        
        $grossPayPerMonthText
            .removeDuplicates()
            .sink { [weak self] newValue in
                guard let self else { return }
                self.settingsStore.grossPayPerMonth = newValue
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
    
    private func setupWorkingTimePublishers() {
        $hoursWorking
            .removeDuplicates()
            .sink { [weak self] hours in
                guard let self else { return }
                self.settingsStore.workTimeInSeconds = self.calculateTimeInSeconds(
                    hours: hours,
                    minutes: self.minutesWorking
                )
            }.store(in: &subscriptions)
        
        $minutesWorking
            .removeDuplicates()
            .sink { [weak self] minutes in
                guard let self else { return }
                self.settingsStore.workTimeInSeconds = self.calculateTimeInSeconds(
                    hours: self.hoursWorking,
                    minutes: minutes
                )
            }.store(in: &subscriptions)
    }
    
    private func setupOvertimePublishers() {
        $hoursOvertime
            .removeDuplicates()
            .sink { [weak self] hours in
                guard let self else { return }
                self.settingsStore.maximumOvertimeAllowedInSeconds = self.calculateTimeInSeconds(
                    hours: hours,
                    minutes: self.minutesOvertime
                )
            }.store(in: &subscriptions)
        
        $minutesOvertime
            .removeDuplicates()
            .sink { [weak self] minutes in
                guard let self else { return }
                self.settingsStore.maximumOvertimeAllowedInSeconds = self.calculateTimeInSeconds(
                    hours: self.hoursOvertime,
                    minutes: minutes
                )
            }.store(in: &subscriptions)
    }
    
    private func setupNotificationSendingPublishers() {
        settingsStore.$isSendingNotification
            .filter { [weak self] value in
                guard let self else { return false }
                return value && !self.authorizationDenied
            }
            .sink { [weak self] _ in
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
    }
    
    private func calculateTimeInSeconds(hours: Int, minutes: Int) -> Int {
        hours * secondsInHour + minutes * secondsInMinute
    }
}

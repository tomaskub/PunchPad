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
    @Published var settingsStore: SettingsStore
    @Published var grossPayPerMonthText: Int
    @Published var hoursWorking: Int
    @Published var minutesWorking: Int
    @Published var hoursOvertime: Int
    @Published var minutesOvertime: Int
    
    init(settingsStore: SettingsStore) {
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
        
        settingsStore.$isSendingNotification.sink { [weak self] value in
            guard let self else { return }
            if value {
                self.requestAuthorizationForNotifications()
            }
        }.store(in: &subscriptions)
    }
    private func calculateTimeInSeconds(hours: Int, minutes: Int) -> Int {
        return hours * 3600 + minutes * 60
    }
    
    func requestAuthorizationForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { [weak self] success, error in
            if success {
                print("Autorization success")
            } else if let error = error {
                print(error.localizedDescription)
                guard let self else { return }
                self.settingsStore.isSendingNotification = false
            }
        })
    }
}

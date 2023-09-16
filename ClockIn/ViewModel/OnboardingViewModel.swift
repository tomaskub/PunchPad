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
    
    @Published var settingsStore: SettingsStore
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var grossPayPerMonthText: String = "" {
        didSet {
            let filtered = grossPayPerMonthText.filter({ "0123456789".contains($0) })
            if let newGross = Int(filtered) {
                settingsStore.grossPayPerMonth = newGross
            }
        }
    }
    
    @Published var hoursWorking: Int = 8 {
        didSet {
            settingsStore.workTimeInSeconds = calculateTimeInSeconds(hours: hoursWorking, minutes: minutesWorking)
        }
    }
    @Published var minutesWorking: Int = 0 {
        didSet {
            settingsStore.workTimeInSeconds = calculateTimeInSeconds(hours: hoursWorking, minutes: minutesWorking)
        }
    }
    
    @Published var hoursOvertime: Int = 5 {
        didSet {
            settingsStore.maximumOvertimeAllowedInSeconds = calculateTimeInSeconds(hours: hoursOvertime, minutes: minutesOvertime)
        }
    }
    @Published var minutesOvertime: Int = 0 {
        didSet {
            settingsStore.maximumOvertimeAllowedInSeconds = calculateTimeInSeconds(hours: hoursOvertime, minutes: minutesOvertime)
        }
    }
    
    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore
        self.hoursWorking = settingsStore.workTimeInSeconds / 3600
        self.minutesWorking = (settingsStore.workTimeInSeconds % 3600) / 60
        self.hoursOvertime = settingsStore.maximumOvertimeAllowedInSeconds / 3600
        self.minutesOvertime = (settingsStore.maximumOvertimeAllowedInSeconds % 3600) / 60
        
        
        $hoursWorking.sink { [weak self] newValue in
            guard let self else { return }
            self.settingsStore.workTimeInSeconds = self.calculateTimeInSeconds(hours: newValue, minutes: self.minutesWorking)
        }.store(in: &subscriptions)
    }
    
    func calculateTimeInSeconds(hours: Int, minutes: Int) -> Int {
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

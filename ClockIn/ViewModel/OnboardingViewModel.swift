//
//  OnboardingViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/23/23.
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    
    @Published private var settingsStore: SettingsStore
    @Published var isLoggingOvertime: Bool {
        didSet {
            UserDefaults.standard.set(isLoggingOvertime, forKey: SettingsStore.SettingKey.isLoggingOvertime.rawValue)//K.UserDefaultsKeys.isLoggingOvertime)
        }
    }
    
    @Published var isSendingNotifications: Bool {
        didSet {
            UserDefaults.standard.set(isSendingNotifications, forKey: K.UserDefaultsKeys.isSendingNotifications)
            if isSendingNotifications {
                //ask for access to notifications
                requestAuthorizationForNotifications()
            }
        }
    }
    
    @Published var netPayAvaliable: Bool {
        didSet {
            UserDefaults.standard.set(netPayAvaliable, forKey: K.UserDefaultsKeys.isCalculatingNetPay)
        }
    }
    
    @Published var grossPayPerMonthText: String = "" {
        didSet {
            let filtered = grossPayPerMonthText.filter({ "0123456789".contains($0) })
            if let newGross = Int(filtered) {
                grossPayPerMonth = newGross
            }
        }
    }
    
    var grossPayPerMonth: Int {
        didSet {
            UserDefaults.standard.set(grossPayPerMonth, forKey: K.UserDefaultsKeys.grossPayPerMonth)
        }
    }
    
    @Published var hoursWorking: Int = 8 {
        didSet {
            workTimeInSeconds = calculateTimeInSeconds(hours: hoursWorking, minutes: minutesWorking)
        }
    }
    @Published var minutesWorking: Int = 0 {
            didSet {
                workTimeInSeconds = calculateTimeInSeconds(hours: hoursWorking, minutes: minutesWorking)
            }
    }
    
    @Published var hoursOvertime: Int = 5 {
        didSet {
            maxOvertimeAllowedinSeconds = calculateTimeInSeconds(hours: hoursOvertime, minutes: minutesOvertime)
        }
    }
    @Published var minutesOvertime: Int = 0 {
        didSet {
            maxOvertimeAllowedinSeconds = calculateTimeInSeconds(hours: hoursOvertime, minutes: minutesOvertime)
        }
    }
    
    
    private var workTimeInSeconds: Int {
        didSet {
            UserDefaults.standard.set(workTimeInSeconds, forKey: K.UserDefaultsKeys.workTimeInSeconds)
        }
    }
    private var maxOvertimeAllowedinSeconds: Int {
        didSet {
            UserDefaults.standard.set(maxOvertimeAllowedinSeconds, forKey: K.UserDefaultsKeys.maximumOverTimeAllowedInSeconds)
        }
    }
    
    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore
        let userDef = UserDefaults.standard
        self.workTimeInSeconds = userDef.integer(forKey: K.UserDefaultsKeys.workTimeInSeconds)
        self.maxOvertimeAllowedinSeconds = userDef.integer(forKey: K.UserDefaultsKeys.maximumOverTimeAllowedInSeconds)
        self.isLoggingOvertime = userDef.bool(forKey: SettingsStore.SettingKey.isLoggingOvertime.rawValue)//K.UserDefaultsKeys.isLoggingOvertime)
        self.isSendingNotifications = userDef.bool(forKey: K.UserDefaultsKeys.isSendingNotifications)
        self.netPayAvaliable = userDef.bool(forKey: K.UserDefaultsKeys.isCalculatingNetPay)
        self.grossPayPerMonth = userDef.integer(forKey: K.UserDefaultsKeys.grossPayPerMonth)
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
                self.isSendingNotifications = false
                UserDefaults.standard.set(self.isSendingNotifications, forKey: K.UserDefaultsKeys.isSendingNotifications)
            }
        })
    }
}

//
//  SettingViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/3/23.
//

import Foundation
import SwiftUI

struct K {
    
    struct UserDefaultsKeys {
        static let isLoggingOvertime = "isLoggingOverTime"
        static let savedColorScheme = "colorScheme"
        static let maximumOverTimeAllowedInSeconds = "overtimeMaximum"
        static let workTimeInSeconds = "workTimeInSeconds"
        static let isSendingNotifications = "isSendingNotifications"
    }
    
    enum ColorScheme: String {
        case system = "system"
        case dark = "dark"
        case light = "light"
    }
    
    struct Notification {
        static let title: String = "Notification title"
        static let body: String = "Notification body"
        static let identifier: String = "ClockIn-work-timer-ended"
    }
}

class SettingsViewModel: ObservableObject {
    
    private var dataManager: DataManager
    
    //View states
    @Published var isShowingWorkTimeEditor: Bool = false
    @Published var isShowingOverTimeEditor: Bool = false
    
    @Published var timerHours: Int = 8 {
        didSet {
            workTimeInSeconds = timerHours * 3600 + timerMinutes * 60
        }
    }
    @Published var timerMinutes: Int = 0 {
        didSet {
            workTimeInSeconds = timerHours * 3600 + timerMinutes * 60
        }
    }
    @Published var overtimeHours: Int = 0 {
        didSet {
            maximumOvertimeAllowedInSeconds = overtimeHours * 3600 + overtimeMinutes * 60
        }
    }
    @Published var overtimeMinutes: Int = 0 {
        didSet {
            maximumOvertimeAllowedInSeconds = overtimeHours * 3600 + overtimeMinutes * 60
        }
    }
        
    
    //UserDefaults
    @Published var isLoggingOverTime: Bool = false {
        didSet {
            //On didSet write to userDefaults
            UserDefaults.standard.set(isLoggingOverTime, forKey: K.UserDefaultsKeys.isLoggingOvertime)
        }
    }
    @Published var preferredColorScheme: String = "system" {
        didSet {
            UserDefaults.standard.set(preferredColorScheme, forKey: K.UserDefaultsKeys.savedColorScheme)
        }
    }
    @Published var maximumOvertimeAllowedInSeconds: Int = 18000 {
        didSet {
            UserDefaults.standard.set(maximumOvertimeAllowedInSeconds, forKey: K.UserDefaultsKeys.maximumOverTimeAllowedInSeconds)
        }
    }
    @Published var isSendingNotifications: Bool = true {
        didSet {
            if isSendingNotifications == true {
                requestAuthorizationForNotifications()
            }
            UserDefaults.standard.set(isSendingNotifications, forKey: K.UserDefaultsKeys.isSendingNotifications)
        }
    }
    private var workTimeInSeconds: Int = 28800 {
        didSet {
            UserDefaults.standard.set(workTimeInSeconds, forKey: K.UserDefaultsKeys.workTimeInSeconds)
        }
    }
    
    init(dataManger: DataManager = DataManager.shared ) {
        self.dataManager = dataManger
        //        on init retrieve values
        self.isLoggingOverTime = UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.isLoggingOvertime)
        self.preferredColorScheme = UserDefaults.standard.string(forKey: K.UserDefaultsKeys.savedColorScheme) ?? "system"
        self.maximumOvertimeAllowedInSeconds = UserDefaults.standard.integer(forKey: K.UserDefaultsKeys.maximumOverTimeAllowedInSeconds)
        self.isSendingNotifications = UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.isSendingNotifications)
        self.workTimeInSeconds = UserDefaults.standard.integer(forKey: K.UserDefaultsKeys.workTimeInSeconds)
        self.timerHours = workTimeInSeconds / 3600
        self.timerMinutes = (workTimeInSeconds % 3600) / 60
    }
    
    func deleteAllData() {
        dataManager.deleteAll()
    }
    
    func resetUserDefaults() {
        isSendingNotifications =  true
        isLoggingOverTime = false
        preferredColorScheme = K.ColorScheme.system.rawValue
        maximumOvertimeAllowedInSeconds = 18000
        workTimeInSeconds = 28800
        timerHours = 8
        timerMinutes = 0
        overtimeHours = 0
        overtimeMinutes = 0
        print("Reseted user defaults to given values")
    }
    
    func requestAuthorizationForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { success, error in
            if success {
                print("Autorization success")
            } else if let error = error {
                print(error.localizedDescription)
            }
        })
    }
}

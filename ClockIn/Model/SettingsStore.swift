//
//  SettingsStore.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 14/09/2023.
//

import SwiftUI

final class SettingsStore: ObservableObject {
    // setting keys - not sure if enum here is what i need for keys
    enum SettingKey: String, CaseIterable {
        case isRunFirstTime
        case isLoggingOvertime
        case isCalculatingNetPay
        case isSendingNotifications
        case maximumOvertimeAllowedInSeconds
        case workTimeInSeconds
        case grossPayPerMonth
        case savedColorScheme
    }
    
    private let defaults = UserDefaults.standard
    
    @Published var isRunFirstTime: Bool {
        didSet {
            updateSetting(setting: .isRunFirstTime, value: isRunFirstTime)
        }
    }
    @Published var isLoggingOvertime: Bool {
        didSet {
            updateSetting(setting: .isLoggingOvertime, value: isLoggingOvertime)
        }
    }
    @Published var isCalculatingNetPay: Bool {
        didSet {
            updateSetting(setting: .isCalculatingNetPay, value: isCalculatingNetPay)
        }
    }
    
    @Published var isSendingNotification: Bool {
        didSet {
            updateSetting(setting: .isSendingNotifications, value: isSendingNotification)
        }
    }
    
    @Published var maximumOvertimeAllowedInSeconds: Int {
        didSet {
            updateSetting(setting: .maximumOvertimeAllowedInSeconds, value: maximumOvertimeAllowedInSeconds)
        }
    }
    
    @Published var workTimeInSeconds: Int {
        didSet {
            updateSetting(setting: .workTimeInSeconds, value: workTimeInSeconds)
        }
    }
    
    @Published var grossPayPerMonth: Int {
        didSet {
            updateSetting(setting: .grossPayPerMonth, value: grossPayPerMonth)
        }
    }
    
    @Published var savedColorScheme: ColorScheme? {
        didSet {
            if let rawValue = savedColorScheme?.rawValue {
                updateSetting(setting: .savedColorScheme, value: rawValue)
            }
        }
    }
    
    init() {
        if let value = defaults.value(forKey: SettingKey.isRunFirstTime.rawValue) as? Bool {
            self.isRunFirstTime = value
        } else {
            self.isRunFirstTime = true
        }
        self.isLoggingOvertime = defaults.bool(forKey: SettingKey.isLoggingOvertime.rawValue)
        self.isCalculatingNetPay = defaults.bool(forKey: SettingKey.isCalculatingNetPay.rawValue)
        self.isSendingNotification = defaults.bool(forKey: SettingKey.isSendingNotifications.rawValue)
        self.maximumOvertimeAllowedInSeconds = defaults.integer(forKey: SettingKey.maximumOvertimeAllowedInSeconds.rawValue)
        self.workTimeInSeconds = defaults.integer(forKey: SettingKey.workTimeInSeconds.rawValue)
        self.grossPayPerMonth = defaults.integer(forKey: SettingKey.grossPayPerMonth.rawValue)
        self.savedColorScheme = ColorScheme.fromStringValue(defaults.string(forKey: SettingKey.savedColorScheme.rawValue))
    }
    
    static func clearUserDefaults() {
        for key in SettingKey.allCases {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }
    
    private func updateSetting<T>(setting: SettingKey, value: T) {
        defaults.set(value, forKey: setting.rawValue)
    }
}

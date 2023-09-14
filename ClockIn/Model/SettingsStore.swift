//
//  SettingsStore.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 14/09/2023.
//

import Foundation

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
    
    var isRunFirstTime: Bool {
        didSet {
            updateSetting(setting: .isRunFirstTime, value: isRunFirstTime)
        }
    }
    var isLoggingOvertime: Bool {
        didSet {
            updateSetting(setting: .isLoggingOvertime, value: isLoggingOvertime)
        }
    }
    var isCalculatingNetPay: Bool {
        didSet {
            updateSetting(setting: .isCalculatingNetPay, value: isCalculatingNetPay)
        }
    }
    
    var isSendingNotification: Bool {
        didSet {
            updateSetting(setting: .isSendingNotifications, value: isSendingNotification)
        }
    }
    
    var maximumOvertimeAllowedInSeconds: Int {
        didSet {
            updateSetting(setting: .maximumOvertimeAllowedInSeconds, value: maximumOvertimeAllowedInSeconds)
        }
    }
    
    var workTimeInSeconds: Int {
        didSet {
            updateSetting(setting: .workTimeInSeconds, value: workTimeInSeconds)
        }
    }
    
    var grossPayPerMonth: Int {
        didSet {
            updateSetting(setting: .grossPayPerMonth, value: grossPayPerMonth)
        }
    }
    
    var savedColorScheme: K.ColorScheme {
        didSet {
            updateSetting(setting: .savedColorScheme, value: savedColorScheme.rawValue)
        }
    }
    
    init() {
        self.isRunFirstTime = defaults.bool(forKey: SettingKey.isRunFirstTime.rawValue)
        self.isLoggingOvertime = defaults.bool(forKey: SettingKey.isLoggingOvertime.rawValue)
        self.isCalculatingNetPay = defaults.bool(forKey: SettingKey.isCalculatingNetPay.rawValue)
        self.isSendingNotification = defaults.bool(forKey: SettingKey.isSendingNotifications.rawValue)
        self.maximumOvertimeAllowedInSeconds = defaults.integer(forKey: SettingKey.maximumOvertimeAllowedInSeconds.rawValue)
        self.workTimeInSeconds = defaults.integer(forKey: SettingKey.workTimeInSeconds.rawValue)
        self.grossPayPerMonth = defaults.integer(forKey: SettingKey.grossPayPerMonth.rawValue)
        self.savedColorScheme = K.ColorScheme(rawValue: defaults.string(forKey: SettingKey.savedColorScheme.rawValue) ?? "system") ?? .system
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

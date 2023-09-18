//
//  SettingsStore.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 14/09/2023.
//

import SwiftUI
import Combine

final class SettingsStore: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    private let defaults = UserDefaults.standard
    
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
    
    @Published var isRunFirstTime: Bool
    @Published var isLoggingOvertime: Bool
    @Published var isCalculatingNetPay: Bool
    @Published var isSendingNotification: Bool
    @Published var maximumOvertimeAllowedInSeconds: Int
    @Published var workTimeInSeconds: Int
    @Published var grossPayPerMonth: Int
    @Published var savedColorScheme: ColorScheme?
    
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
        self.setUpSubscribersSavingToUserDefaults()
    }
    
    func setUpSubscribersSavingToUserDefaults() {
        $isRunFirstTime
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                self.updateSetting(setting: .isRunFirstTime, value: value)
            }.store(in: &subscriptions)
        $isLoggingOvertime
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                self.updateSetting(setting: .isLoggingOvertime, value: value)
            }.store(in: &subscriptions)
        $isCalculatingNetPay
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                self.updateSetting(setting: .isCalculatingNetPay, value: value)
            }.store(in: &subscriptions)
        $isSendingNotification
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                self.updateSetting(setting: .isSendingNotifications, value: value)
            }.store(in: &subscriptions)
     $maximumOvertimeAllowedInSeconds
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                self.updateSetting(setting: .maximumOvertimeAllowedInSeconds, value: value)
            }.store(in: &subscriptions)
        $workTimeInSeconds
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                self.updateSetting(setting: .workTimeInSeconds, value: value)
            }.store(in: &subscriptions)
        $grossPayPerMonth
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self else { return }
                self.updateSetting(setting: .grossPayPerMonth, value: value)
            }.store(in: &subscriptions)
        $savedColorScheme
            .removeDuplicates()
            .sink { [weak self] value  in
                guard let self else { return }
                self.updateSetting(setting: .savedColorScheme, value: value)
            }.store(in: &subscriptions)
    }
    
    func clearStore() {
        subscriptions.removeAll()
        for key in SettingKey.allCases {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        if let value = defaults.value(forKey: SettingKey.isRunFirstTime.rawValue) as? Bool {
            self.isRunFirstTime = value
        } else {
            self.isRunFirstTime = true
        }
        isLoggingOvertime = defaults.bool(forKey: SettingKey.isLoggingOvertime.rawValue)
        isCalculatingNetPay = defaults.bool(forKey: SettingKey.isCalculatingNetPay.rawValue)
        isSendingNotification = defaults.bool(forKey: SettingKey.isSendingNotifications.rawValue)
        maximumOvertimeAllowedInSeconds = defaults.integer(forKey: SettingKey.maximumOvertimeAllowedInSeconds.rawValue)
        workTimeInSeconds = defaults.integer(forKey: SettingKey.workTimeInSeconds.rawValue)
        grossPayPerMonth = defaults.integer(forKey: SettingKey.grossPayPerMonth.rawValue)
        savedColorScheme = ColorScheme.fromStringValue(defaults.string(forKey: SettingKey.savedColorScheme.rawValue))
        setUpSubscribersSavingToUserDefaults()
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

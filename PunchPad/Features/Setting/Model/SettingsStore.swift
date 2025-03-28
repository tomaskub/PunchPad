//
//  SettingsStore.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 14/09/2023.
//

import SwiftUI
import Combine
import OSLog

final class SettingsStore: ObservableObject {
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
    
    private var subscriptions = Set<AnyCancellable>()
    private let defaults = UserDefaults.standard
    private var logger = Logger.settingsStore
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
        self.maximumOvertimeAllowedInSeconds = defaults.integer(
            forKey: SettingKey.maximumOvertimeAllowedInSeconds.rawValue
        )
        self.workTimeInSeconds = defaults.integer(forKey: SettingKey.workTimeInSeconds.rawValue)
        self.grossPayPerMonth = defaults.integer(
            forKey: SettingKey.grossPayPerMonth.rawValue
        )
        self.savedColorScheme = ColorScheme.fromStringValue(
            defaults.string(forKey: SettingKey.savedColorScheme.rawValue)
        )
        self.setUpSubscribersSavingToUserDefaults()
    }
    
    func setUpSubscribersSavingToUserDefaults() {
        logger.debug("setUpSubscribers called")
        
        boolPublishersWithKeys
            .forEach { key, publisher in
                publisher
                    .dropFirst()
                    .removeDuplicates()
                    .sink { [weak self] value in
                        self?.updateSetting(setting: key, value: value)
                    }.store(in: &subscriptions)
        }
        
        intPublishersWithKeys
            .forEach { key, publisher in
                publisher
                    .dropFirst()
                    .removeDuplicates()
                    .sink { [weak self] value in
                        self?.updateSetting(setting: key, value: value)
                    }.store(in: &subscriptions)
        }

        $savedColorScheme
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] value  in
                guard let self else { return }
                self.updateSetting(setting: .savedColorScheme, value: value)
            }.store(in: &subscriptions)
    }
    
    func clearStore() {
        logger.debug("clearStore called")
        subscriptions.removeAll()
        for key in SettingKey.allCases {
            if key != .isRunFirstTime {
                UserDefaults.standard.removeObject(forKey: key.rawValue)
            } else {
                updateSetting(setting: key, value: false)
            }
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
        Logger.settingsStore.debug("clearUserDefaults called")
        for key in SettingKey.allCases {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }
    
    static func setTestUserDefaults() {
        Logger.settingsStore.debug("setTestUserDefaults called")
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: SettingKey.isRunFirstTime.rawValue)
        defaults.set(true, forKey: SettingKey.isLoggingOvertime.rawValue)
        defaults.set(true, forKey: SettingKey.isCalculatingNetPay.rawValue)
        defaults.set(false, forKey: SettingKey.isSendingNotifications.rawValue)
        defaults.set(28800, forKey: SettingKey.workTimeInSeconds.rawValue)
        defaults.set(14400, forKey: SettingKey.maximumOvertimeAllowedInSeconds.rawValue)
        defaults.set(10000, forKey: SettingKey.grossPayPerMonth.rawValue)
        defaults.set(nil as ColorScheme?, forKey: SettingKey.savedColorScheme.rawValue)
    }
    
    private func updateSetting<T>(setting: SettingKey, value: T) {
        logger.debug("updateSetting called for key: \(setting.rawValue)")
        defaults.set(value, forKey: setting.rawValue)
    }
}

extension SettingsStore {
    var boolPublishersWithKeys: [SettingKey: Published<Bool>.Publisher] {
        [
            .isRunFirstTime: $isRunFirstTime,
            .isLoggingOvertime: $isLoggingOvertime,
            .isCalculatingNetPay: $isCalculatingNetPay,
            .isSendingNotifications: $isSendingNotification
        ]
    }
    var intPublishersWithKeys: [SettingKey: Published<Int>.Publisher] {
        [
            .maximumOvertimeAllowedInSeconds: $maximumOvertimeAllowedInSeconds,
            .workTimeInSeconds: $workTimeInSeconds,
            .grossPayPerMonth: $grossPayPerMonth
        ]
    }
}

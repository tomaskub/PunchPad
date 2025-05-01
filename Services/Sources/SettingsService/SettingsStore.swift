//
//  SettingsStore.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 14/09/2023.
//

import Combine
import DomainModels
import OSLog
import SwiftUI
import SettingsServiceInterfaces
import FoundationExtensions

public final class SettingsStore: ObservableObject, SettingsStoring, TestDefaultsSetting {
    public var isRunFirstTimePublisher: Published<Bool>.Publisher { $isRunFirstTime }
    public var isLoggingOvertimePublisher: Published<Bool>.Publisher { $isLoggingOvertime }
    public var isCalculatingNetPayPublisher: Published<Bool>.Publisher { $isCalculatingNetPay }
    public var isSendingNotificationPublisher: Published<Bool>.Publisher { $isSendingNotification }
    public var maximumOvertimeAllowedInSecondsPublisher: Published<Int>.Publisher { $maximumOvertimeAllowedInSeconds }
    public var workTimeInSecondsPublisher: Published<Int>.Publisher { $workTimeInSeconds }
    public var grossPayPerMonthPublisher: Published<Int>.Publisher { $grossPayPerMonth }

    @Published public var isRunFirstTime: Bool
    @Published public var isLoggingOvertime: Bool
    @Published public var isCalculatingNetPay: Bool
    @Published public var isSendingNotification: Bool
    @Published public var maximumOvertimeAllowedInSeconds: Int
    @Published public var workTimeInSeconds: Int
    @Published public var grossPayPerMonth: Int
    
    private var subscriptions = Set<AnyCancellable>()
    private let defaults = UserDefaults.standard
    private var logger = Logger.settingsStore

    public init() {
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
        self.setUpSubscribersSavingToUserDefaults()
    }
    
    private func setUpSubscribersSavingToUserDefaults() {
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
    }
    
    public func clearStore() {
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
        setUpSubscribersSavingToUserDefaults()
    }
    
    public static func clearUserDefaults() {
        Logger.settingsStore.debug("clearUserDefaults called")
        for key in SettingKey.allCases {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }
    
    public static func setTestUserDefaults() {
        Logger.settingsStore.debug("setTestUserDefaults called")
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: SettingKey.isRunFirstTime.rawValue)
        defaults.set(true, forKey: SettingKey.isLoggingOvertime.rawValue)
        defaults.set(true, forKey: SettingKey.isCalculatingNetPay.rawValue)
        defaults.set(false, forKey: SettingKey.isSendingNotifications.rawValue)
        defaults.set(28800, forKey: SettingKey.workTimeInSeconds.rawValue)
        defaults.set(14400, forKey: SettingKey.maximumOvertimeAllowedInSeconds.rawValue)
        defaults.set(10000, forKey: SettingKey.grossPayPerMonth.rawValue)
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

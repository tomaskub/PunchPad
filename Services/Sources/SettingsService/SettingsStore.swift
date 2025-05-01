//
//  SettingsStore.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 14/09/2023.
//

import Combine
import DomainModels
import Foundation
import FoundationExtensions
import SettingsServiceInterfaces

public final class SettingsStore: ObservableObject, SettingsStoring {
    public var isRunFirstTimePublisher: Published<Bool>.Publisher { $isRunFirstTime }
    public var isLoggingOvertimePublisher: Published<Bool>.Publisher { $isLoggingOvertime }
    public var isCalculatingNetPayPublisher: Published<Bool>.Publisher { $isCalculatingNetPay }
    public var isSendingNotificationPublisher: Published<Bool>.Publisher { $isSendingNotification }
    public var maximumOvertimeAllowedInSecondsPublisher: Published<Int>.Publisher { $maximumOvertimeAllowedInSeconds }
    public var workTimeInSecondsPublisher: Published<Int>.Publisher { $workTimeInSeconds }
    public var grossPayPerMonthPublisher: Published<Int>.Publisher { $grossPayPerMonth }

    @Published public var isRunFirstTime = false
    @Published public var isLoggingOvertime = false
    @Published public var isCalculatingNetPay = false
    @Published public var isSendingNotification = false
    @Published public var maximumOvertimeAllowedInSeconds = 0
    @Published public var workTimeInSeconds = 0
    @Published public var grossPayPerMonth = 0
    
    var subscriptions = Set<AnyCancellable>()
    let defaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
        if let value = defaults.value(forKey: SettingKey.isRunFirstTime.rawValue) as? Bool {
            self.isRunFirstTime = value
        } else {
            self.isRunFirstTime = true
        }
        loadValuesFromDefaults()
        self.setUpSubscribersSavingToUserDefaults()
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
        loadValuesFromDefaults()
        setUpSubscribersSavingToUserDefaults()
    }
}

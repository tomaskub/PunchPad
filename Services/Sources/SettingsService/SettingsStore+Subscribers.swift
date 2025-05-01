import Combine
import DomainModels

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
    }
}

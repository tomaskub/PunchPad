import DomainModels
import Foundation

extension SettingsStore {
    func updateSetting<T>(setting: SettingKey, value: T) {
        logger.debug("updateSetting called for key: \(setting.rawValue)")
        defaults.set(value, forKey: setting.rawValue)
    }
    
    func loadValuesFromDefaults() {
        isLoggingOvertime = defaults.bool(for: .isLoggingOvertime)
        isCalculatingNetPay = defaults.bool(for: .isCalculatingNetPay)
        isSendingNotification = defaults.bool(for:.isSendingNotifications)
        maximumOvertimeAllowedInSeconds = defaults.integer(for: .maximumOvertimeAllowedInSeconds)
        workTimeInSeconds = defaults.integer(for: .workTimeInSeconds)
        grossPayPerMonth = defaults.integer(for: .grossPayPerMonth)
    }
}

fileprivate extension UserDefaults {
    func bool(for key: SettingKey) -> Bool {
        self.bool(forKey: key.rawValue)
    }
    
    func integer(for key: SettingKey) -> Int {
        self.integer(forKey: key.rawValue)
    }
}

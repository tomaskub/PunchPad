import DomainModels
import Foundation
import SettingsServiceInterfaces

extension SettingsStore: TestDefaultsSetting {
    public static func clearUserDefaults() {
        logger.debug("clearUserDefaults called")
        for key in SettingKey.allCases {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }
    
    public static func setTestUserDefaults() {
        logger.debug("setTestUserDefaults called")
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: SettingKey.isRunFirstTime.rawValue)
        defaults.set(true, forKey: SettingKey.isLoggingOvertime.rawValue)
        defaults.set(true, forKey: SettingKey.isCalculatingNetPay.rawValue)
        defaults.set(false, forKey: SettingKey.isSendingNotifications.rawValue)
        defaults.set(28800, forKey: SettingKey.workTimeInSeconds.rawValue)
        defaults.set(14400, forKey: SettingKey.maximumOvertimeAllowedInSeconds.rawValue)
        defaults.set(10000, forKey: SettingKey.grossPayPerMonth.rawValue)
    }
}

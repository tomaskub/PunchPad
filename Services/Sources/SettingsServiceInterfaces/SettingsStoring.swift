import Combine

public protocol SettingsStoring: AnyObject, ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    var isRunFirstTime: Bool { get set }
    var isLoggingOvertime: Bool { get set }
    var isCalculatingNetPay: Bool { get set }
    var isSendingNotification: Bool { get set }
    var maximumOvertimeAllowedInSeconds: Int { get set }
    var workTimeInSeconds: Int { get set }
    var grossPayPerMonth: Int { get set }
    
    var isRunFirstTimePublisher: Published<Bool>.Publisher { get }
    var isLoggingOvertimePublisher: Published<Bool>.Publisher { get }
    var isCalculatingNetPayPublisher: Published<Bool>.Publisher { get }
    var isSendingNotificationPublisher: Published<Bool>.Publisher { get }
    var maximumOvertimeAllowedInSecondsPublisher: Published<Int>.Publisher { get }
    var workTimeInSecondsPublisher: Published<Int>.Publisher { get }
    var grossPayPerMonthPublisher: Published<Int>.Publisher { get }
}

public protocol TestDefaultsSetting {
    static func clearUserDefaults()
    static func setTestUserDefaults()
}

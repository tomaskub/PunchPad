import Combine
import SettingsServiceInterfaces

public final class MockSettingsService: ObservableObject, SettingsStoring {
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

    /// Initialize with default testing values
    public convenience init() {
        self.init(isRunFirstTime: false,
                  isLoggingOvertime: true,
                  isCalculatingNetPay: true,
                  isSendingNotification: false,
                  maximumOvertimeAllowedInSeconds: 28800,
                  workTimeInSeconds: 14400,
                  grossPayPerMonth: 10000)
    }
    
    public init(isRunFirstTime: Bool,
                isLoggingOvertime: Bool,
                isCalculatingNetPay: Bool,
                isSendingNotification: Bool,
                maximumOvertimeAllowedInSeconds: Int,
                workTimeInSeconds: Int,
                grossPayPerMonth: Int) {
        self.isRunFirstTime = isRunFirstTime
        self.isLoggingOvertime = isLoggingOvertime
        self.isCalculatingNetPay = isCalculatingNetPay
        self.isSendingNotification = isSendingNotification
        self.maximumOvertimeAllowedInSeconds = maximumOvertimeAllowedInSeconds
        self.workTimeInSeconds = workTimeInSeconds
        self.grossPayPerMonth = grossPayPerMonth
    }
    
    public func clearStore() {
        isRunFirstTime = false
        isLoggingOvertime = false
        isCalculatingNetPay = false
        isSendingNotification = false
        maximumOvertimeAllowedInSeconds = 0
        workTimeInSeconds = 0
        grossPayPerMonth = 0
    }
    
}

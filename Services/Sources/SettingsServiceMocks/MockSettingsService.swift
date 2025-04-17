import Combine
import SettingsServiceInterfaces
import SwiftUI // TODO: Remove color scheme

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
    @Published public var savedColorScheme: ColorScheme?

    public init() {
        self.isRunFirstTime = false
        self.isLoggingOvertime = true
        self.isCalculatingNetPay = true
        self.isSendingNotification = false
        self.workTimeInSeconds = 28800
        self.maximumOvertimeAllowedInSeconds = 14400
        self.grossPayPerMonth = 10000
        self.savedColorScheme = nil
    }
}

import NotificationServiceInterfaces
import UserNotifications

public final class WrappedUNUserNotificationCenter: UserNotificationCenter {
    private let center: UNUserNotificationCenter
    
    public init(center: UNUserNotificationCenter) {
        self.center = center
    }
    
    public func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, (any Error)?) -> Void) {
        center.requestAuthorization(options: options, completionHandler: completionHandler)
    }
    
    public func removeAllPendingNotificationRequests() {
        center.removeAllPendingNotificationRequests()
    }
    
    public func notificationSettings() async -> UNNotificationSettings {
        await center.notificationSettings()
    }
    
    public func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {
        center.getNotificationSettings(completionHandler: completionHandler)
    }
    
    public func add(_ request: UNNotificationRequest, withCompletionHandler: (((any Error)?) -> Void)?) {
        center.add(request, withCompletionHandler: withCompletionHandler)
    }
}

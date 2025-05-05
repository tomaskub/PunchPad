import DomainModels
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
    
    public func getNotificationSettings(completionHandler: @escaping (UserNotificationSettings) -> Void) {
        center.getNotificationSettings { settings in
            completionHandler(UserNotificationCenterAdapter.get(from: settings))
        }
    }
    
    public func add(_ request: UNNotificationRequest, withCompletionHandler: (((any Error)?) -> Void)?) {
        center.add(request, withCompletionHandler: withCompletionHandler)
    }
}

class UserNotificationCenterAdapter {
    static func get(from settings: UNNotificationSettings) -> UserNotificationSettings {
        .init(authorizationStatus: settings.authorizationStatus)
    }
}

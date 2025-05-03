import DomainModels
import UserNotifications

public protocol UserNotificationCenter {
    func requestAuthorization(options: UNAuthorizationOptions,
                              completionHandler: @escaping (Bool, (any Error)?) -> Void)
    func removeAllPendingNotificationRequests()
    func notificationSettings() async -> UserNotificationSettings
    func getNotificationSettings(completionHandler: @escaping (UserNotificationSettings) -> Void)
    func add(_: UNNotificationRequest, withCompletionHandler: (((any Error)?) -> Void)?)
}

public extension UserNotificationCenter {
    func add(_ request: UNNotificationRequest) {
        add(request, withCompletionHandler: nil)
    }
}

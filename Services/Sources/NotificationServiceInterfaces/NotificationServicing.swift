import DomainModels
import Foundation

public protocol NotificationServicing: AnyObject {
    func requestAuthorizationForNotifications(failureHandler: @escaping (Bool, Error?) -> Void)
    func deschedulePendingNotifications()
    func checkForAuthorization() async -> Bool?
    func checkForAuthorization(completionHandler: @escaping (Bool?) -> Void)
    func scheduleNotification(for: AppNotification, in: TimeInterval)
}

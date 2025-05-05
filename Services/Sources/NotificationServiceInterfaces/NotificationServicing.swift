import DomainModels
import Foundation

public protocol NotificationServicing: AnyObject {
    func requestAuthorizationForNotifications(failureHandler: @escaping (Bool, Error?) -> Void)
    func deschedulePendingNotifications()
    func scheduleNotification(for: AppNotification, in: TimeInterval)
}

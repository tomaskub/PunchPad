import DomainModels
import Foundation
import NotificationServiceInterfaces

public final class NotificationServiceMock: NotificationServicing {
    public init() {}
    
    var requestAuthorizationForNotificationsCalled = false
    var requestAuthorizationForNotificationReturn: Bool = false
    var requestAuthorizationForNotificationError: NotificationsMockError?
    
    public func requestAuthorizationForNotifications(failureHandler: @escaping (Bool, (any Error)?) -> Void) {
        requestAuthorizationForNotificationsCalled = true
        failureHandler(requestAuthorizationForNotificationReturn,
                       requestAuthorizationForNotificationError)
    }
    
    var deschedulePendingNotificationsCalled = false
    
    public func deschedulePendingNotifications() {
        deschedulePendingNotificationsCalled = true
    }
    
    var checkForAuthorizationCalled = false
    var checkForAuthorizationReturn: Bool?
    
    public func checkForAuthorization() async -> Bool? {
        checkForAuthorizationCalled = true
        return checkForAuthorizationReturn
    }
    
    var checkForAuthorizationWithHandlerCalled = false
    var checkForAuthorizationWithHandlerReturn: Bool?
    
    public func checkForAuthorization(completionHandler: @escaping (Bool?) -> Void) {
        checkForAuthorizationWithHandlerCalled = true
        completionHandler(checkForAuthorizationWithHandlerReturn)
    }
    
    var scheduleNotificationCalled = false
    var notificationToSchedule: [(AppNotification, TimeInterval)] = []
    
    public func scheduleNotification(for notification: AppNotification, in timeInterval: TimeInterval) {
                scheduleNotificationCalled = true
        notificationToSchedule.append((notification, timeInterval))
    }
}

public enum NotificationsMockError: Error {
    case error
}

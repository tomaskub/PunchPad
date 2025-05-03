import NotificationServiceInterfaces
import UserNotifications

public final class UserNotificationCenterMock: UserNotificationCenter {
    var requestAuthorizationCalled = false
    var requestAuthorizationOptions: UNAuthorizationOptions?
    var requestAuthorizationCompletionHandler: ((Bool, (any Error)?) -> Void)?
    
    var requestAuthorizationShouldFailError: Error?
    var requestAuthorizationReturn = false
    
    public func requestAuthorization(options: UNAuthorizationOptions,
                                     completionHandler: @escaping (Bool, (any Error)?) -> Void) {
        requestAuthorizationCalled = true
        requestAuthorizationOptions = options
        requestAuthorizationCompletionHandler = completionHandler
        
        completionHandler(requestAuthorizationReturn, requestAuthorizationShouldFailError)
    }
    
    var removeAllPendingNotificationRequestsCalled = false
    
    public func removeAllPendingNotificationRequests() {
        removeAllPendingNotificationRequestsCalled = true
    }
    
    public func notificationSettings() async -> UNNotificationSettings {
        fatalError("Mock of this method is not implemented")
    }
    
    public func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {
        fatalError("Mock of this method is not implemented")
    }
    
    var addCalled: Bool { addRequest == nil ? false : true }
    var addRequest: UNNotificationRequest?
    var addShouldFailError: Error?
    
    public func add(_ request: UNNotificationRequest, withCompletionHandler: (((any Error)?) -> Void)?) {
        addRequest = request
        withCompletionHandler?(addShouldFailError)
    }
}

import DomainModels
import NotificationServiceInterfaces
import UserNotifications

public final class UserNotificationCenterMock: UserNotificationCenter {
    public init() {}
   
    public var requestAuthorizationCalled = false
    public var requestAuthorizationOptions: UNAuthorizationOptions?
    public var requestAuthorizationCompletionHandler: ((Bool, (any Error)?) -> Void)?
    
    public var requestAuthorizationShouldFailError: Error?
    public var requestAuthorizationReturn = false
    
    public func requestAuthorization(options: UNAuthorizationOptions,
                                     completionHandler: @escaping (Bool, (any Error)?) -> Void) {
        requestAuthorizationCalled = true
        requestAuthorizationOptions = options
        requestAuthorizationCompletionHandler = completionHandler
        
        completionHandler(requestAuthorizationReturn, requestAuthorizationShouldFailError)
    }
    
    public var removeAllPendingNotificationRequestsCalled = false
    
    public func removeAllPendingNotificationRequests() {
        removeAllPendingNotificationRequestsCalled = true
    }
    
    public var getNotificationSettingsCalled = false
    public var getNotificationSettingsReturn = UserNotificationSettings(authorizationStatus: .notDetermined)
    
    public func getNotificationSettings(completionHandler: @escaping (UserNotificationSettings) -> Void) {
        getNotificationSettingsCalled = true
        completionHandler(getNotificationSettingsReturn)
    }
    
    public var addCalled: Bool { addRequest == nil ? false : true }
    public var addRequest: UNNotificationRequest?
    public var addShouldFailError: Error?
    
    public func add(_ request: UNNotificationRequest, withCompletionHandler: (((any Error)?) -> Void)?) {
        addRequest = request
        withCompletionHandler?(addShouldFailError)
    }
}

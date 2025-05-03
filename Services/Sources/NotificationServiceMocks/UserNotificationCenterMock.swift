import DomainModels
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
    
    var notificationSettingsCalled = false
    var notificationSettingsReturn = UserNotificationSettings(authorizationStatus: .notDetermined)
    
    public func notificationSettings() async -> UserNotificationSettings {
        notificationSettingsCalled = true
        return notificationSettingsReturn
    }
    
    var getNotificationSettingsCalled = false
    var getNotificationSettingsReturn = UserNotificationSettings(authorizationStatus: .notDetermined)
    
    public func getNotificationSettings(completionHandler: @escaping (UserNotificationSettings) -> Void) {
        getNotificationSettingsCalled = true
        completionHandler(getNotificationSettingsReturn)
    }
    
    var addCalled: Bool { addRequest == nil ? false : true }
    var addRequest: UNNotificationRequest?
    var addShouldFailError: Error?
    
    public func add(_ request: UNNotificationRequest, withCompletionHandler: (((any Error)?) -> Void)?) {
        addRequest = request
        withCompletionHandler?(addShouldFailError)
    }
}

import UserNotifications

public class UserNotificationSettings {
    public var authorizationStatus: UNAuthorizationStatus
    
    public init(authorizationStatus: UNAuthorizationStatus) {
        self.authorizationStatus = authorizationStatus
    }
    
    required init?(coder: NSCoder) {
        nil
    }
}

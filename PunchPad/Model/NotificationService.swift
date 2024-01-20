//
//  NotificationService.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 20/01/2024.
//

import Foundation
import UserNotifications

class NotificationService {
    let center: UNUserNotificationCenter
    var pendingNotificationsIDs: Set<String> = []
    
    init(center: UNUserNotificationCenter) {
        self.center = center
    }
    
    func requestAuthorizationForNotifications(failureHandler: @escaping (Bool, Error?) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if !success {
                // setting in store should be false
                failureHandler(success, error) // <- this happens when user does not accept the notifications
            }
            if let error {
                print(error.localizedDescription)
            }
        }
    }
    func deschedulePendingNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    func scheduleNotification(for notification: AppNotification, in timeInterval: TimeInterval) {
        let id = UUID().uuidString
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = notification.title
        notificationContent.body = notification.body
        
        let request = UNNotificationRequest(identifier: id,
                                            content: notificationContent,
                                            trigger: trigger)
        checkForPermissionAndDispatch(request)
    }
    
    func checkForPermissionAndDispatch(_ notificationRequest: UNNotificationRequest) {
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatch(notification: notificationRequest)
            default:
                return
            }
        }
    }
    
    func dispatch(notification: UNNotificationRequest) {
        _ = pendingNotificationsIDs.insert(notification.identifier)
        center.add(notification)
    }
    
}

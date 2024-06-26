//
//  NotificationService.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 20/01/2024.
//

import Foundation
import UserNotifications

final class NotificationService {
    private let center: UNUserNotificationCenter
    private var pendingNotificationsIDs: Set<String> = []
    
    init(center: UNUserNotificationCenter) {
        self.center = center
    }
    
    func requestAuthorizationForNotifications(failureHandler: @escaping (Bool, Error?) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if !success {
                failureHandler(success, error)
            }
            if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func deschedulePendingNotifications() {
        center.removeAllPendingNotificationRequests()
        pendingNotificationsIDs.removeAll()
    }
    
    func checkForAuthorization() async -> Bool? {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            return nil
        case .denied:
            return false
        case .authorized, .provisional, .ephemeral:
            return true
        @unknown default:
            return nil
        }
    }
    
    func checkForAuthorization(completionHandler: @escaping (Bool?) -> Void) {
        center.getNotificationSettings { settings in
            let value: Bool? = {
                switch settings.authorizationStatus {
                case .notDetermined:
                    return nil
                case .denied:
                    return false
                case .authorized, .provisional, .ephemeral:
                    return true
                @unknown default:
                    return nil
                }
            }()
            completionHandler(value)
        }
    }
    
    func scheduleNotification(for notification: AppNotification, in timeInterval: TimeInterval) {
        let id = UUID().uuidString
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = notification.title
        notificationContent.body = notification.body
        notificationContent.interruptionLevel = .active
        
        let request = UNNotificationRequest(identifier: id,
                                            content: notificationContent,
                                            trigger: trigger)
        checkForPermissionAndDispatch(request)
    }
    
    private func checkForPermissionAndDispatch(_ notificationRequest: UNNotificationRequest) {
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatch(notification: notificationRequest)
            default:
                return
            }
        }
    }
    
    private func dispatch(notification: UNNotificationRequest) {
        _ = pendingNotificationsIDs.insert(notification.identifier)
        center.add(notification)
    }
    
}

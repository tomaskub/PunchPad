//
//  NotificationService.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 20/01/2024.
//

import Foundation
import UserNotifications
import OSLog

final class NotificationService {
    private let center: UNUserNotificationCenter
    private var pendingNotificationsIDs: Set<String> = []
    private let logger = Logger.notificationService
    
    init(center: UNUserNotificationCenter) {
        self.center = center
    }
    
    func requestAuthorizationForNotifications(failureHandler: @escaping (Bool, Error?) -> Void) {
        logger.debug("requestAuthorization called")
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] success, error in
            if !success {
                self?.logger.debug("Failed to get authorization")
                failureHandler(success, error)
            } else {
                self?.logger.debug("Authorization successfull")
            }
            if let error {
                self?.logger.error("When requesting authorization: \(error.localizedDescription)")
            }
        }
    }
    
    func deschedulePendingNotifications() {
        logger.debug("deschedulePendingNotifications called")
        center.removeAllPendingNotificationRequests()
        pendingNotificationsIDs.removeAll()
    }
    
    func checkForAuthorization() async -> Bool? {
        logger.debug("checkForAuthorization called")
        let settings = await center.notificationSettings()
        logger.debug("Authorization status retrieved: \(settings.authorizationStatus.debugDescription)")
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
        logger.debug("checkForAuthorization called")
        center.getNotificationSettings { [weak self] settings in
            self?.logger.debug("Authorization status retrieved: \(settings.authorizationStatus.debugDescription)")
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
        logger.debug("scheduleNotification called")
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
        logger.debug("checkForPermissionAndDispatch called")
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.logger.debug("Recieved authorized status")
                self.dispatch(notification: notificationRequest)
            default:
                return
            }
        }
    }
    
    private func dispatch(notification: UNNotificationRequest) {
        logger.debug("dispatch called")
        _ = pendingNotificationsIDs.insert(notification.identifier)
        center.add(notification)
    }
    
}

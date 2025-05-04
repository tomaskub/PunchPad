//
//  NotificationService.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 20/01/2024.
//

import DomainModels
import Foundation
import FoundationExtensions
import NotificationServiceInterfaces
import OSLog
import UserNotifications

public final class NotificationService: NotificationServicing {
    private let center: UserNotificationCenter
    private var pendingNotificationsIDs: Set<String> = []
    
    public init(center: UserNotificationCenter) {
        self.center = center
    }
    
    public func requestAuthorizationForNotifications(failureHandler: @escaping (Bool, Error?) -> Void) {
        logger.debug("requestAuthorization called")
        center.requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if !success {
                logger.debug("Failed to get authorization")
                failureHandler(success, error)
            } else {
                logger.debug("Authorization successfull")
            }
            if let error {
                logger.error("When requesting authorization: \(error.localizedDescription)")
            }
        }
    }
    
    public func deschedulePendingNotifications() {
        logger.debug("deschedulePendingNotifications called")
        center.removeAllPendingNotificationRequests()
        pendingNotificationsIDs.removeAll()
    }
    
    public func scheduleNotification(for notification: AppNotification, in timeInterval: TimeInterval) {
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
                logger.debug("Recieved authorized status")
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

extension AppNotification {
    var title: String {
        switch self {
        case .workTime:
            return Strings.titleWorktime
        case .overTime:
            return Strings.titleOvertime
        }
    }
    
    var body: String {
        switch self {
        case .workTime:
            return Strings.bodyWorktime
        case .overTime:
            return Strings.bodyOvertime
        }
    }
}

// TODO: inverstigate @retroactive
extension AppNotification: Localized {
    public struct Strings {
        static let titleWorktime = Localization.AppNotificationScreen.worktimeFinished
        static let titleOvertime = Localization.AppNotificationScreen.overtimeFinished
        static let bodyWorktime = Localization.AppNotificationScreen.congratulationsYouFinishedNormalHours
        static let bodyOvertime = Localization.AppNotificationScreen.congratulationsYouFinishedOvertime
    }
}

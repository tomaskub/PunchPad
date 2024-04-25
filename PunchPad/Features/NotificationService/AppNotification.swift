//
//  AppNotification.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 20/01/2024.
//

import Foundation

enum AppNotification {
    case workTime
    case overTime
    
    /// Title for the notification
    var title: String {
        switch self {
        case .workTime:
            return Strings.titleWorktime
        case .overTime:
            return Strings.titleOvertime
        }
    }
    
    /// Body message for notification
    var body: String {
        switch self {
        case .workTime:
            return Strings.bodyWorktime
        case .overTime:
            return Strings.bodyOvertime
        }
    }
}

extension AppNotification: Localized {
    struct Strings {
        static let titleWorktime = Localization.AppNotificationScreen.worktimeFinished
        static let titleOvertime = Localization.AppNotificationScreen.overtimeFinished
        static let bodyWorktime = Localization.AppNotificationScreen.congratulationsYouFinishedNormalHours
        static let bodyOvertime = Localization.AppNotificationScreen.congratulationsYouFinishedOvertime
    }
}

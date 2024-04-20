//
//  Localization.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 20/04/2024.
//

import Foundation

struct Localization {
    struct Onboarding {
        static let backButtonTitleText = String(localized: "Back")
        
        struct BottomButton {
            static let letsStart = String(localized: "Let's start!")
            static let finish = String(localized: "Finish set up!")
            static let next = String(localized: "Next")
        }
    }
    
    struct OnboardingWelcome {
        static let description = String(localized: "This app was built to help you track time and make sure you are spending at work exactly the time you want and need. \n\n Plan your workdays and plan your paycheck!")
    }
    
    struct OnbardingWorktime {
        static let workday = String(localized: "Workday")
        static let hours = String(localized: "Hours")
        static let minutes = String(localized: "Minutes")
        static let description = String(localized: "PunchPad needs to know your normal workday length to let you know when you are done or when you enter into overtime")
    }
    
    struct OnboardingOvertime {
        static let overtime = String(localized: "Overtime")
        static let letMeasureOvertime = "Let PunchPad know wheter you want to measure overtime"
        static let letKnowMaximumOvertime = String(localized: "Let the app know maximum overtime you can work for.")
        static let hours = String(localized: "Hours")
        static let minutes = String(localized: "Minutes")
        static let keepLoggingOvertime = String(localized: "Keep logging overtime")
    }
    
    struct OnboardingNotification {
        static let notifications = String(localized: "Notifications")
        static let descriptionText = String(localized: "Do you want PunchPad to send you notifications when the work time is finished?")
        static let sendNotificationsOnFinish = String(localized: "Send notifications on finish")
        static let needsPermission = String(localized: "PunchPad needs permission to show notifications")
        static let allowForNotifications = String(localized: "You need to allow for notification in settings")
        static let ok = String(localized: "OK")
    }
}

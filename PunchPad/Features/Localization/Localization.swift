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
}

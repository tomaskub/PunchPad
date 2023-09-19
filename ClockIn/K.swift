//
//  K.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/21/23.
//

import Foundation

struct K {
    struct Notification {
        static let title: String = "Work timer finished!"
        static let body: String = "Congratulations! You are finished with your normal hours! Stop the timer in the app to clock out or stay for that sweet overtime pay!"
        static let identifier: String = "ClockIn-work-timer-ended"
    }
}

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
            return "Work finished!"
        case .overTime:
            return "Overtime finished!"
        }
    }
    
    /// Body message for notification
    var body: String {
        switch self {
        case .workTime:
            return "Congratulations! You are finished with your normal hours!"
        case .overTime:
            return "Congratulations! You finished with your overtime!"
        }
    }
}

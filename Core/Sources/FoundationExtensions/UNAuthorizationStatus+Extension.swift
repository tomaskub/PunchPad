//
//  UNAuthorizationStatus+Extension.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 02/09/2024.
//

import Foundation
import NotificationCenter

public extension UNAuthorizationStatus {
    var debugDescription: String {
        switch self {
        case .notDetermined:
            return "notDetermined"
        case .denied:
            return "denied"
        case .authorized:
            return "authorized"
        case .provisional:
            return "provisional"
        case .ephemeral:
            return "ephemeral"
        @unknown default:
            return "notImplemented"
        }
    }
}

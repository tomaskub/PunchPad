//
//  TimerServiceState.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 15/05/2024.
//

import Foundation

enum TimerServiceState: Codable {
    case running, paused, notStarted, finished
    
    var debugDescription: String {
        String(describing: self)
    }
}

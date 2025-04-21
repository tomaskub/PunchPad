//
//  TimerServiceState.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 15/05/2024.
//

import Foundation

public enum TimerServiceState: Codable {
    case running, paused, notStarted, finished
    
    public var debugDescription: String {
        String(describing: self)
    }
}

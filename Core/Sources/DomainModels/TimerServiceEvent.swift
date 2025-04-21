//
//  TimerServiceEvent.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 15/05/2024.
//

import Foundation
public enum TimerServiceEvent {
    case start, stop, pause, resumeWith(TimeInterval?)
    
    public var debugDescription: String {
        String(describing: self)
    }
}

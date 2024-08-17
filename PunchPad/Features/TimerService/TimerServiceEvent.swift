//
//  TimerServiceEvent.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 15/05/2024.
//

import Foundation
enum TimerServiceEvent {
    case start, stop, pause, resumeWith(TimeInterval?)
}

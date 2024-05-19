//
//  TimerModel.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 15/05/2024.
//

import Foundation

struct TimerModel: Codable {
    let configuration: TimerManagerConfiguration
    let workTimeCounter: TimeInterval
    let overtimeCounter: TimeInterval?
    let workTimerState: TimerServiceState
    let overtimeTimerState: TimerServiceState?
    let timeStamp: Date
}

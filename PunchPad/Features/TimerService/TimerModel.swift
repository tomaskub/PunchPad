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
    
    static func initial(configuration: TimerManagerConfiguration) -> TimerModel {
        return TimerModel(configuration: configuration,
                          workTimeCounter: 0,
                          overtimeCounter: 0,
                          workTimerState: .notStarted,
                          overtimeTimerState: configuration.isLoggingOvertime ? .notStarted : nil,
                          timeStamp: .now)
    }
}

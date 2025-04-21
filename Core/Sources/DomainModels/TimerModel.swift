//
//  TimerModel.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 15/05/2024.
//

import Foundation

public struct TimerModel: Codable {
    public let configuration: TimerManagerConfiguration
    public let workTimeCounter: TimeInterval
    public let overtimeCounter: TimeInterval?
    public let workTimerState: TimerServiceState
    public let overtimeTimerState: TimerServiceState?
    public let timeStamp: Date
    
    public init(configuration: TimerManagerConfiguration,
                workTimeCounter: TimeInterval,
                overtimeCounter: TimeInterval?,
                workTimerState: TimerServiceState,
                overtimeTimerState: TimerServiceState?,
                timeStamp: Date) {
        self.configuration = configuration
        self.workTimeCounter = workTimeCounter
        self.overtimeCounter = overtimeCounter
        self.workTimerState = workTimerState
        self.overtimeTimerState = overtimeTimerState
        self.timeStamp = timeStamp
    }
    
    public static func initial(configuration: TimerManagerConfiguration) -> TimerModel {
        return TimerModel(configuration: configuration,
                          workTimeCounter: 0,
                          overtimeCounter: 0,
                          workTimerState: .notStarted,
                          overtimeTimerState: configuration.isLoggingOvertime ? .notStarted : nil,
                          timeStamp: .now)
    }
}

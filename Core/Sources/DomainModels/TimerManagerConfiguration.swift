//
//  TimerManagerConfiguration.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 18/05/2024.
//

import Foundation

public struct TimerManagerConfiguration: Codable {
    public let workTimeInSeconds: TimeInterval
    public let isLoggingOvertime: Bool
    public let overtimeInSeconds: TimeInterval?
}

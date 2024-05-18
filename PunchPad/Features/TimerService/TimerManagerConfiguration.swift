//
//  TimerManagerConfiguration.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 18/05/2024.
//

import Foundation

struct TimerManagerConfiguration: Codable {
    let workTimeInSeconds: TimeInterval
    let isLoggingOvertime: Bool
    let overtimeInSeconds: TimeInterval?
}

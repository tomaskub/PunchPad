//
//  Logger+Extension.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 18/08/2024.
//

import Foundation
import OSLog

extension Logger {
    static let subsystem = Bundle.main.bundleIdentifier!
    static let timerService = Logger(subsystem: subsystem, category: "TimerService")
}

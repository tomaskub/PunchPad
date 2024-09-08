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
    static let timerStore = Logger(subsystem: subsystem, category: "TimerStore")
    static let timerManager = Logger(subsystem: subsystem, category: "TimerManager")
    static let containerService = Logger(subsystem: subsystem, category: "Container")
    static let payManager = Logger(subsystem: subsystem, category: "PayManager")
    static let notificationService = Logger(subsystem: subsystem, category: "NotificationService")
    static let persistanceContainer = Logger(subsystem: subsystem, category: "PersistanceContainer")
    static let dataManager = Logger(subsystem: subsystem, category: "DataManager")
    static let chartService = Logger(subsystem: subsystem, category: "ChartPeriodService")
    static let statisticsViewModel = Logger(subsystem: subsystem, category: "StatisticsViewModel")
}

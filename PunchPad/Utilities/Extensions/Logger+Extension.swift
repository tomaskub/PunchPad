//
//  Logger+Extension.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 18/08/2024.
//

import Foundation
import OSLog

extension Logger {
    private enum Category: String {
        case timerService
        case timerStore
        case timerManager
        case containerService
        case payManager
        case notificationService
        case persistanceContainer
        case dataManager
        case chartService
        case statisticsViewModel
        case settingsStore
        case historyViewModel
        case editSheetViewModel
    }
    
    static let timerService = logger(for: .timerService)
    static let timerStore = logger(for: .timerStore)
    static let timerManager = logger(for: .timerManager)
    static let containerService = logger(for: .containerService)
    static let payManager = logger(for: .payManager)
    static let notificationService = logger(for: .notificationService)
    static let persistanceContainer = logger(for: .persistanceContainer)
    static let dataManager = logger(for: .dataManager)
    static let chartService = logger(for: .chartService)
    static let statisticsViewModel = logger(for: .statisticsViewModel)
    static let settingsStore = logger(for: .settingsStore)
    static let historyViewModel = logger(for: .historyViewModel)
    static let editSheetViewModel = logger(for: .editSheetViewModel)
    private static let subsystem = Bundle.main.bundleIdentifier!

    private static func logger(for category: Category) -> Logger {
        return Logger(subsystem: subsystem,
                      category: category.rawValue.capitalized)
    }
}

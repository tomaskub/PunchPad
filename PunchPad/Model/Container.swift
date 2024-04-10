//
//  Container.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 12/09/2023.
//

import Foundation
import Combine

final class Container: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    private(set) var dataManager: DataManager
    private(set) var payManager: PayManager
    private(set) var timerProvider: Timer.Type
    private(set) var settingsStore: SettingsStore
    private(set) var notificationService: NotificationService
    
    private enum ContainerType {
        case production, test, preview
    }
    
    init() {
        self.timerProvider = Timer.self
        var containerType: ContainerType = .production
        
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            containerType = .preview
            SettingsStore.setTestUserDefaults()
        }
        
        if CommandLine.arguments.contains(LaunchArgument.withOnboarding.rawValue) {
            SettingsStore.clearUserDefaults()
        } else if CommandLine.arguments.contains(LaunchArgument.setTestUserDefaults.rawValue) {
            SettingsStore.setTestUserDefaults()
        }
        self.settingsStore = SettingsStore()
        
        if CommandLine.arguments.contains(LaunchArgument.inMemoryPresistenStore.rawValue) {
            containerType = .test
        }
        
        switch containerType {
        case .production:
            self.dataManager = .shared
            self.payManager = PayManager(dataManager: .shared, settingsStore: settingsStore, calendar: .current)
        case .test:
            self.dataManager = .testing
            self.payManager = PayManager(dataManager: .testing, settingsStore: settingsStore, calendar: .current)
        case .preview:
            self.dataManager = .preview
            self.payManager = PayManager(dataManager: .preview, settingsStore: settingsStore, calendar: .current)
        }
        self.notificationService = NotificationService(center: .current())
    }
}

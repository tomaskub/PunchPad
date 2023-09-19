//
//  Container.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 12/09/2023.
//

import Foundation
import Combine

class Container: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    private(set) var dataManager: DataManager
    private(set) var payManager: PayManager
    private(set) var timerProvider: Timer.Type
    private(set) var settingsStore: SettingsStore
    
    enum ContainerType {
        case production, test, preview
    }
    
    init() {
        self.timerProvider = Timer.self
        var containerType: ContainerType = .production
        
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            containerType = .preview
        }
        
        if CommandLine.arguments.contains(LaunchArgument.withOnboarding.rawValue) {
            SettingsStore.clearUserDefaults()
            self.settingsStore = SettingsStore()
            settingsStore.isRunFirstTime = true
            containerType = .test
        } else {
            self.settingsStore = SettingsStore()
        }
        
        if CommandLine.arguments.contains(LaunchArgument.inMemoryPresistenStore.rawValue) {
            containerType = .test
        }
        if CommandLine.arguments.contains(LaunchArgument.setTestUserDefaults.rawValue) {
            UserDefaults.standard.set(false, forKey: SettingsStore.SettingKey.isRunFirstTime.rawValue)
            containerType = .test
        }
        
        switch containerType {
        case .production:
            self.dataManager = .shared
            self.payManager = PayManager(dataManager: .shared)
        case .test:
            self.dataManager = .testing
            self.payManager = PayManager(dataManager: .testing)
        case .preview:
            self.dataManager = .preview
            self.payManager = PayManager(dataManager: .preview)
        }
    }
}

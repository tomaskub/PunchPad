//
//  Container.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 12/09/2023.
//

import Foundation

class Container: ObservableObject {
    
    private(set) var dataManager: DataManager
    private(set) var payManager: PayManager
    private(set) var timerProvider: Timer.Type
    
    enum ContainerType {
        case production, test, preview
    }
    
    init() {
        var containerType: ContainerType = .production
        
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            containerType = .preview
        }
        
        if CommandLine.arguments.contains(LaunchArgument.withOnboarding.rawValue) {
            K.resetUserDefaults()
            UserDefaults.standard.set(true, forKey: K.UserDefaultsKeys.isRunFirstTime)
            containerType = .test
        }
        
        if CommandLine.arguments.contains(LaunchArgument.inMemoryPresistenStore.rawValue) {
            containerType = .test
        }
        if CommandLine.arguments.contains(LaunchArgument.setTestUserDefaults.rawValue) {
            UserDefaults.standard.set(false, forKey: K.UserDefaultsKeys.isRunFirstTime)
            containerType = .test
        }
        
        self.timerProvider = Timer.self
        
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

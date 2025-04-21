//
//  LaunchArgumentsHandler.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 30/01/2025.
//

import DomainModels
import Foundation
import SettingsServiceInterfaces

public struct LaunchArgumentsHandler<T: TestDefaultsSetting> {
    let userDefaults: UserDefaults
    
    public init(userDefaultsSetter: T.Type, userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    public func handleLaunch() {
        setTestUserDefaultsIfNeeded()
        startWithOnboardingIfNeeded()
    }
    
    public func shouldSetInMemoryPersistentStore() -> Bool {
        guard
            CommandLine.arguments.contains(LaunchArgument.inMemoryPresistenStore.rawValue)
        else { return false  }
        return true
    }
    
    private func setTestUserDefaultsIfNeeded() {
        guard
            CommandLine.arguments.contains(LaunchArgument.setTestUserDefaults.rawValue)
        else { return }
        
        T.setTestUserDefaults()
    }
    
    private func startWithOnboardingIfNeeded() {
        guard
            CommandLine.arguments.contains(LaunchArgument.withOnboarding.rawValue)
        else { return }

        T.clearUserDefaults()
        UserDefaults.standard.set(
            true,
            forKey: SettingKey.isRunFirstTime.rawValue
        )
    }
}

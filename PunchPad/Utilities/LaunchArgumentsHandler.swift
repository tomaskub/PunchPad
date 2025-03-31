//
//  LaunchArgumentsHandler.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 30/01/2025.
//

import Foundation

struct LaunchArgumentsHandler {
    let userDefaults: UserDefaults
    
    func handleLaunch() {
        setTestUserDefaultsIfNeeded()
        startWithOnboardingIfNeeded()
    }
    
    func shouldSetInMemoryPersistentStore() -> Bool {
        guard
            CommandLine.arguments.contains(LaunchArgument.inMemoryPresistenStore.rawValue)
        else { return false  }
        return true
    }
    
    private func setTestUserDefaultsIfNeeded() {
        guard
            CommandLine.arguments.contains(LaunchArgument.setTestUserDefaults.rawValue)
        else { return }
        
        SettingsStore.setTestUserDefaults()
    }
    
    private func startWithOnboardingIfNeeded() {
        guard
            CommandLine.arguments.contains(LaunchArgument.withOnboarding.rawValue)
        else { return }

        SettingsStore.clearUserDefaults()
        UserDefaults.standard.set(
            true,
            forKey: SettingsStore.SettingKey.isRunFirstTime.rawValue
        )
    }
}

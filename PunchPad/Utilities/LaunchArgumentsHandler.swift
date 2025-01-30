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
        startWithOnboardingIfNeeded()
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

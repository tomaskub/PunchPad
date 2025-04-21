//
//  ClockInApp.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/27/23.
//

import ContainerService
import DomainModels
import NavigationKit
import SwiftUI

@main
struct ClockInApp: App {
    private let appNavigator: Navigator = Navigator(Route.main)
    private let container: ContainerProtocol
    @AppStorage(SettingKey.savedColorScheme.rawValue) var preferredColorScheme: String?
    
    init() {
        // Handle first
        let handler = LaunchArgumentsHandler(userDefaults: .standard)
        handler.handleLaunch()
        
        let container = resolveContainerType()
        self.container = container
    }
    
    var colorScheme: ColorScheme? {
        switch preferredColorScheme {
        case .none:
            return nil
        case .some(let wrapped):
            return ColorScheme.fromStringValue(wrapped)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView(
                navigator: appNavigator,
                container: container
            )
                .preferredColorScheme(colorScheme)
        }
    }
}

fileprivate func resolveContainerType() -> Container {
    let handler = LaunchArgumentsHandler(userDefaults: .standard)
    
    if handler.shouldSetInMemoryPersistentStore() {
        let dataManager = TestDataManager()
        return Container(dataManaging: dataManager)
    } else {
        return Container()
    }
}

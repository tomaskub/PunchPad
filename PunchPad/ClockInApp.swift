//
//  ClockInApp.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/27/23.
//

import SwiftUI
import NavigationKit

@main
struct ClockInApp: App {
    private let appNavigator: Navigator = Navigator(Route.main)
    private let container: ContainerProtocol
    @AppStorage(SettingsStore.SettingKey.savedColorScheme.rawValue) var preferredColorScheme: String?
    
    init() {
        self.container = Container()
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
            ContentView(navigator: appNavigator,
                        container: container
            )
                .preferredColorScheme(colorScheme)
        }
    }
}

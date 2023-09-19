//
//  ClockInApp.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/27/23.
//

import SwiftUI

@main
struct ClockInApp: App {
    
    @StateObject private var container = Container()
    @AppStorage(SettingsStore.SettingKey.savedColorScheme.rawValue) var preferredColorScheme: String?
    
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
            ContentView()
                .environmentObject(container)
                .preferredColorScheme(colorScheme)
        }
    }
}

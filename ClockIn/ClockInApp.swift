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
    @AppStorage("colorScheme") var preferredColorScheme: String = "system"
    
    var colorScheme: ColorScheme? {
        switch preferredColorScheme {
        case "dark":
            return ColorScheme.dark
        case "light":
            return ColorScheme.light
        default:
            return nil
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

//
//  ContentView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/27/23.
//

import SwiftUI
import TabViewKit
import NavigationKit

struct ContentView: View {
    let navigator: Navigator<Route>
    @State private var tabSelection: TabBarItem = .home
    @EnvironmentObject var container: Container
    @AppStorage(SettingsStore.SettingKey.isRunFirstTime.rawValue) var isRunFirstTime: Bool = true 
    
    var body: some View {
        NavHost(navigator: navigator) { route in
            switch route {
            case .main:
                MainView(navigator: navigator,
                         tabSelection: $tabSelection,
                         container: container
                )
            case .settings:
                SettingsView(viewModel:
                                SettingsViewModel(
                                    dataManger: container.dataManager,
                                    settingsStore: container.settingsStore
                                )
                )
            }
        }
        .fullScreenCover(isPresented: $isRunFirstTime, onDismiss: {
            isRunFirstTime = false
        }) {
            OnboardingView(viewModel: OnboardingViewModel(settingsStore: container.settingsStore))
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(navigator: Navigator(Route.main))
            .environmentObject(Container())
    }
}

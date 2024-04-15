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
    private let navigator: Navigator<Route>
    @State private var tabSelection: TabBarItem = .home
    @EnvironmentObject private var container: Container
    @AppStorage(SettingsStore.SettingKey.isRunFirstTime.rawValue) private var isRunFirstTime: Bool = true
    
    init(navigator: Navigator<Route>) {
        self.navigator = navigator
    }
    
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
                                SettingsViewModel(dataManger: container.dataManager,
                                                  notificationService: container.notificationService,
                                                  settingsStore: container.settingsStore
                                                 )
                )
            }
        }
        .fullScreenCover(isPresented: $isRunFirstTime, onDismiss: {
            isRunFirstTime = false
        }) {
            OnboardingView(viewModel: 
                            OnboardingViewModel(notificationService: container.notificationService,
                                                settingsStore: container.settingsStore)
            )
        }
    }
}

#Preview("ContentView") {
    struct ContainerView: View {
        var body: some View {
            ContentView(navigator: Navigator(Route.main))
                .environmentObject(Container())
        }
    }
    return ContainerView()
}
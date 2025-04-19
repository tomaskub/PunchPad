//
//  ContentView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/27/23.
//

import ContainerService
import DomainModels
import NavigationKit
import Onboarding
import Settings
import SwiftUI
import TabViewKit

struct ContentView: View {
    private let navigator: Navigator<Route>
    private let container: ContainerProtocol
    @State private var tabSelection: TabBarItem = .home
    @AppStorage(SettingKey.isRunFirstTime.rawValue) private var isRunFirstTime: Bool = true
    
    init(navigator: Navigator<Route>, container: ContainerProtocol) {
        self.navigator = navigator
        self.container = container
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
                                SettingsViewModel(
                                    dataManger: container.dataManager,
                                    notificationService: container.notificationService,
                                    settingsStore: container.settingsStore
                                )
                )
            }
        }
        .fullScreenCover(isPresented: $isRunFirstTime, onDismiss: {
            isRunFirstTime = false
        }, content: {
            OnboardingView(viewModel:
                            OnboardingViewModel(notificationService: container.notificationService,
                                                settingsStore: container.settingsStore)
            )
        })
    }
}

#Preview("ContentView") {
    struct ContainerView: View {
        var body: some View {
            ContentView(
                navigator: Navigator(Route.main),
                container: PreviewContainer()
            )
        }
    }
    return ContainerView()
}

//
//  ContentView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/27/23.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var container: Container
    @AppStorage(SettingsStore.SettingKey.isRunFirstTime.rawValue) var isRunFirstTime: Bool = true 
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView(viewModel:
                            HomeViewModel(dataManager: container.dataManager,
                                          settingsStore: container.settingsStore, 
                                          payManager: container.payManager,
                                          timerProvider: container.timerProvider)
                )
            }
            .tabItem {
                Label("Home", systemImage: "house")
                    .accessibilityIdentifier(ScreenIdentifier.TabBar.home.rawValue)
            }
            NavigationView {
                StatisticsView(viewModel:
                                StatisticsViewModel(dataManager: container.dataManager,
                                                    payManager: container.payManager,
                                                    settingsStore: container.settingsStore)
                )
            }
            .tabItem {
                Label("Statistics", systemImage: "chart.bar.xaxis")
                    .accessibilityIdentifier(ScreenIdentifier.TabBar.statistics.rawValue)
            }
            NavigationView {
                HistoryView(viewModel:
                                HistoryViewModel(dataManager: container.dataManager,
                                                 settingsStore: container.settingsStore)
                )
            }
            .tabItem {
                Label("History", systemImage: "rectangle.grid.1x2.fill")
                    .accessibilityIdentifier(ScreenIdentifier.TabBar.history.rawValue)
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
        ContentView()
            .environmentObject(Container())
    }
}

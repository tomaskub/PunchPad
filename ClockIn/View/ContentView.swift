//
//  ContentView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/27/23.
//

import SwiftUI
import TabViewKit

struct ContentView: View {
    @State private var tabSelection: TabBarItem = .home
    @EnvironmentObject var container: Container
    @AppStorage(SettingsStore.SettingKey.isRunFirstTime.rawValue) var isRunFirstTime: Bool = true 
    
    var body: some View {
        CustomTabView(selection: $tabSelection) {
            NavigationView {
                HomeView(viewModel:
                            HomeViewModel(dataManager: container.dataManager,
                                          settingsStore: container.settingsStore,
                                          payManager: container.payManager,
                                          timerProvider: container.timerProvider)
                )
            }
            .tabBarItem(tab: .home, selection: $tabSelection)
            NavigationView {
                StatisticsView(viewModel:
                                StatisticsViewModel(dataManager: container.dataManager,
                                                    payManager: container.payManager,
                                                    settingsStore: container.settingsStore)
                )
            }
            .tabBarItem(tab: .statistics, selection: $tabSelection)
            NavigationView {
                HistoryView(viewModel:
                                HistoryViewModel(dataManager: container.dataManager,
                                                 settingsStore: container.settingsStore)
                )
            }
            .tabBarItem(tab: .history, selection: $tabSelection)
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

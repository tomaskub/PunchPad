//
//  MainView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 30/12/2023.
//

import SwiftUI
import TabViewKit

struct MainView: View {
    @Binding var tabSelection: TabBarItem
    @EnvironmentObject var container: Container
    
    var body: some View {
        CustomTabView(selection: $tabSelection) {
            HomeView(viewModel:
                        HomeViewModel(dataManager: container.dataManager,
                                      settingsStore: container.settingsStore,
                                      payManager: container.payManager,
                                      timerProvider: container.timerProvider)
            )
            .tabBarItem(tab: .home, selection: $tabSelection)
            
            StatisticsView(viewModel:
                            StatisticsViewModel(dataManager: container.dataManager,
                                                payManager: container.payManager,
                                                settingsStore: container.settingsStore)
            )
            .tabBarItem(tab: .statistics, selection: $tabSelection)
            
            HistoryView(viewModel:
                            HistoryViewModel(dataManager: container.dataManager,
                                             settingsStore: container.settingsStore)
            )
            .tabBarItem(tab: .history, selection: $tabSelection)
        }
    }
}

#Preview {
    MainView(tabSelection: .constant(.home))
        .environmentObject(Container())
}

//
//  MainView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 30/12/2023.
//

import SwiftUI
import TabViewKit
import NavigationKit

struct MainView: View {
    let navigator: Navigator<Route>
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
        .navigationBarTitle(generateNavTitle(tabSelection))
        .navigationBarBackground(bg: {
            BackgroundFactory.buildNavBarBackground()
        })
        .navigationBarTrailingItem {
            toolbar
        }
    }
    func generateNavTitle(_ tabSelection: TabBarItem) -> String {
        tabSelection == .home ? "PunchPad" : tabSelection.title
    }
    var toolbar: some View {
        Label("Settings", systemImage: "gearshape")
            .fixedSize()
            .onTapGesture {
                navigator.push(.settings)
            }
    }
}

//TODO: FIGURE OUT WHY NAV HOST GENERATES BLANK SCREEN WHEN NAV BAR BACKGROUND IS ADDED
#Preview("No navigation bar") {
    MainView(navigator: Navigator(Route.main),
             tabSelection: .constant(.home)
    )
    .environmentObject(Container())
}

#Preview("With navHost") {
    struct Preview: View {
        var body: some View {
            NavHost(navigator: Navigator(Route.main)){ _ in
                MainView(navigator: Navigator(Route.main),tabSelection: .constant(.home))
                    .environmentObject(Container())
            }
        }
    }
    return Preview()
    }

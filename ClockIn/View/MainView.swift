//
//  MainView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 30/12/2023.
//

import SwiftUI
import TabViewKit
import NavigationKit
import ThemeKit

struct MainView: View {
    let navigator: Navigator<Route>
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var statViewModel: StatisticsViewModel
    @StateObject private var historyViewModel: HistoryViewModel
    @State private var isShowingFiltering: Bool = false
    @State private var selectedEntry: Entry? = nil
    @Binding var tabSelection: TabBarItem
    @EnvironmentObject var container: Container
    let mainTitle: AttributedString = {
        var result = AttributedString("PunchPad")
        result.font = .title
        result.foregroundColor = .theme.black
        if let range = result.range(of: "Punch") {
            result[range].font = .title.weight(.heavy)
        }
        return result
    }()
    
    init(navigator: Navigator<Route>, tabSelection: Binding<TabBarItem>, container: Container) {
        self.navigator = navigator
        
        self._homeViewModel = .init(wrappedValue:
                                        HomeViewModel(dataManager: container.dataManager,
                                                      settingsStore: container.settingsStore,
                                                      payManager: container.payManager,
                                                      timerProvider: container.timerProvider)
        )
        
        self._statViewModel = .init(wrappedValue:
                                        StatisticsViewModel(dataManager: container.dataManager,
                                                            payManager: container.payManager,
                                                            settingsStore: container.settingsStore)
        )
        self._historyViewModel = .init(wrappedValue:
                                        HistoryViewModel(dataManager: container.dataManager,
                                                         settingsStore: container.settingsStore)
        )
        self._tabSelection = tabSelection
    }
    
    var body: some View {
        CustomTabView(selection: $tabSelection) {
            HomeView(viewModel: homeViewModel)
                .tabBarItem(tab: .home, selection: $tabSelection)
            
            StatisticsView(viewModel: statViewModel)
                .tabBarItem(tab: .statistics, selection: $tabSelection)
            
            HistoryView(viewModel: historyViewModel, selectedEntry: $selectedEntry, isShowingFiltering: $isShowingFiltering)
                .tabBarItem(tab: .history, selection: $tabSelection)
        }
        .navigationBarTitle(generateNavTitle(tabSelection))
        .navigationBarBackground(bg: {
            BackgroundFactory.buildNavBarBackground()
        })
        .navigationBarItems {
            leadingToolbar
        } trailing: {
            trailingToolbar
        }
        .navigationBarTrailingItem {
            trailingToolbar
        }
    }
    
    @ViewBuilder
    var leadingToolbar: some View {
        switch tabSelection {
        case .home:
            Logo.logo()
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .foregroundColor(.theme.primary)
        case .history:
            makeToolBarItemIcon("plus")
                .onTapGesture {
                    selectedEntry = Entry()
                }
        case .statistics:
            EmptyView()
        }
    }
    @ViewBuilder
    var trailingToolbar: some View {
        switch tabSelection {
        case .home, .statistics:
            makeToolBarItemIcon("gearshape")
                .onTapGesture {
                    navigator.push(.settings)
                }
            
        case .history:
            HStack {
                makeToolBarItemIcon("line.3.horizontal.decrease.circle")
                    .onTapGesture {
                        isShowingFiltering.toggle()
                    }
                
                makeToolBarItemIcon("gearshape")
                    .onTapGesture {
                        navigator.push(.settings)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func makeToolBarItemIcon(_ sysName: String) -> some View {
        Image(systemName: sysName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 28, height: 28)
            .foregroundColor(.theme.primary)
    }
    
    func generateNavTitle(_ tabSelection: TabBarItem) -> AttributedString {
        guard !(tabSelection == .home) else { return mainTitle }
        var result = AttributedString(tabSelection.title)
        result.font = .title.weight(.medium)
        result.foregroundColor = .theme.black
        return result
    }
}

#Preview("No navigation bar") {
    struct Preview: View {
        @StateObject private var container: Container = .init()
        
        var body: some View {
            MainView(navigator: Navigator(Route.main),
                     tabSelection: .constant(.home),
                     container: container
            )
            .environmentObject(container)
        }
    }
    return Preview()
}

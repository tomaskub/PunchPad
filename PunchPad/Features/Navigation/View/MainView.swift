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
    private let navigator: Navigator<Route>
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var statViewModel: StatisticsViewModel
    @StateObject private var historyViewModel: HistoryViewModel
    @State private var isShowingFiltering: Bool = false
    @State private var selectedEntry: Entry? = nil
    @Binding private var tabSelection: TabBarItem
    private let container: ContainerProtocol
    private let mainTitle: AttributedString = {
        var result = AttributedString("PunchPad")
        result.font = .title
        result.foregroundColor = .theme.black
        if let range = result.range(of: "Punch") {
            result[range].font = .title.weight(.heavy)
        }
        return result
    }()
    private let tabBarColorConfiguration = TabBarColorConfiguration(activeColor: .theme.primary,
                                                                    inactiveColor: .theme.secondaryLabel,
                                                                    shadowColor: .theme.black.opacity(0.3),
                                                                    backgroundColor: .theme.white)
    
    init(navigator: Navigator<Route>, tabSelection: Binding<TabBarItem>, container: ContainerProtocol) {
        self.navigator = navigator
        
        self._homeViewModel = .init(wrappedValue:
                                        HomeViewModel(dataManager: container.dataManager,
                                                      settingsStore: container.settingsStore,
                                                      payManager: container.payManager,
                                                      notificationService: container.notificationService,
                                                      timerProvider: container.timerProvider)
        )
        
        self._statViewModel = .init(wrappedValue:
                                        StatisticsViewModel(dataManager: container.dataManager,
                                                            payManager: container.payManager,
                                                            settingsStore: container.settingsStore,
                                                            calendar: .current)
        )
        self._historyViewModel = .init(wrappedValue:
                                        HistoryViewModel(dataManager: container.dataManager,
                                                         settingsStore: container.settingsStore)
        )
        self._tabSelection = tabSelection
        self.container = container
    }
}

//MARK: - Body
extension MainView {
    var body: some View {
        CustomTabView(selection: $tabSelection,
                      tabBarColorConfiguration: tabBarColorConfiguration) {
            HomeView(viewModel: homeViewModel)
                .tabBarItem(tab: .home, selection: $tabSelection)
            
            StatisticsView(viewModel: statViewModel)
                .tabBarItem(tab: .statistics, selection: $tabSelection)
            
            HistoryView(viewModel: historyViewModel, 
                        selectedEntry: $selectedEntry,
                        isShowingFiltering: $isShowingFiltering,
                        container: container)
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
    }
}

//MARK: - View Builders
private extension MainView {
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
                    selectedEntry = historyViewModel.newEntry()
                }
                .accessibilityIdentifier(ScreenIdentifier.HistoryView.addEntryButton)
            
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
                .accessibilityIdentifier(ScreenIdentifier
                    .NavigationElements
                    .NavigationBarButtons
                    .settingNavigationButton)
            
        case .history:
            HStack {
                makeToolBarItemIcon("line.3.horizontal.decrease.circle")
                    .onTapGesture {
                        isShowingFiltering.toggle()
                    }
                    .accessibilityIdentifier(ScreenIdentifier.HistoryView.filterButton)
                
                makeToolBarItemIcon("gearshape")
                    .onTapGesture {
                        navigator.push(.settings)
                    }
                    .accessibilityIdentifier(ScreenIdentifier
                        .NavigationElements
                        .NavigationBarButtons
                        .settingNavigationButton)
            }
        }
    }
    
    @ViewBuilder
    func makeToolBarItemIcon(_ sysName: String) -> some View {
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
        private let container = PreviewContainer()
        
        var body: some View {
            MainView(navigator: Navigator(Route.main),
                     tabSelection: .constant(.home),
                     container: container
            )
        }
    }
    return Preview()
}

//
//  TabBarItem.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 28/12/2023.
//

enum TabBarItem: Hashable {
    case home, history, statistics
    
    var iconName: String {
        switch  self {
        case .home:
            "house.fill"
        case .history:
            "rectangle.grid.1x2.fill"
        case .statistics:
            "chart.bar.xaxis"
        }
    }
    var title: String {
        switch  self {
        case .home:
            "Home"
        case .history:
            "History"
        case .statistics:
            "Statistics"
        }
    }
    
    var identifier: String {
        switch self {
        case .home:
            ScreenIdentifier.TabBar.home.rawValue
        case .history:
            ScreenIdentifier.TabBar.history.rawValue
        case .statistics:
            ScreenIdentifier.TabBar.statistics.rawValue
        }
    }
}

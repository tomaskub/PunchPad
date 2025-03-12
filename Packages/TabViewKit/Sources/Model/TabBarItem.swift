//
//  TabBarItem.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 28/12/2023.
//

public enum TabBarItem: Hashable {
    case home, history, statistics
    
    public var iconName: String {
        switch  self {
        case .home:
            "house.fill"
        case .history:
            "rectangle.grid.1x2.fill"
        case .statistics:
            "chart.bar.xaxis"
        }
    }
    
    public var title: String {
        switch  self {
        case .home:
            "Home"
        case .history:
            "History"
        case .statistics:
            "Statistics"
        }
    }
    
    public var identifier: String {
        switch self {
        case .home:
            TabBarIdentifier.home.rawValue
        case .history:
            TabBarIdentifier.history.rawValue
        case .statistics:
            TabBarIdentifier.statistics.rawValue
        }
    }
}

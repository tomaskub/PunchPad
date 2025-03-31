//
//  ChartTimeRange.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 27/12/2023.
//

import Foundation

public enum ChartTimeRange: String, Identifiable, CaseIterable {
    case week, month, year, all
    
    public var id: ChartTimeRange { self }
    
    public var description: String {
        switch self {
        case .week:
            "week"
        case .month:
            "month"
        case .year:
            "year"
        case .all:
            "all"
        }
    }
}

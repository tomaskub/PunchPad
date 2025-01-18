//
//  ChartTimeRange.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 27/12/2023.
//

import Foundation

enum ChartTimeRange: String, Identifiable, CaseIterable {
    case week, month, year, all
    
    var id: ChartTimeRange { self }
    
    var description: String {
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

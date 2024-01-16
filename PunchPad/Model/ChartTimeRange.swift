//
//  ChartTimeRange.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 27/12/2023.
//

import Foundation

enum ChartTimeRange: String, Identifiable, CaseIterable {
    var id: ChartTimeRange { self }
    case week, month, year, all
}

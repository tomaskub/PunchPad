//
//  ChartableEntry.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 11/02/2024.
//

import Foundation

public protocol ChartableEntry: Identifiable, Hashable {
    var id: UUID { get }
    var startDate: Date { get }
    var workTimeInSeconds: Int { get }
    var overTimeInSeconds: Int { get }
}

//
//  MonthEntrySummary.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 28/12/2023.
//

import Foundation

struct EntrySummary: ChartableEntry {
    let id: UUID
    let startDate: Date
    let workTimeInSeconds: Int
    let overTimeInSeconds: Int
    
    init(startDate: Date, workTimeInSeconds: Int, overTimeInSeconds: Int) {
        self.id = UUID()
        self.startDate = startDate
        self.workTimeInSeconds = workTimeInSeconds
        self.overTimeInSeconds = overTimeInSeconds
    }
    
    init(fromEntries array: [Entry]) {
        let startDate = array.first?.startDate ?? Date()
        let workTimeSum = array.map({ $0.workTimeInSeconds }).reduce(0, +)
        let overtimeSum = array.map({ $0.overTimeInSeconds }).reduce(0, +)
        self.init(startDate: startDate, workTimeInSeconds: workTimeSum, overTimeInSeconds: overtimeSum)
    }
}

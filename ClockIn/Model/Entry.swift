//
//  Entry.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/2/23.
//

import Foundation

//front facing struct that seperates views from the coreData objects 

struct Entry: Identifiable, Hashable {
    var id: UUID
    var startDate: Date
    var finishDate: Date
    var workTime: Double
    var overTime: Double
    
    init(startDate: Date, finishDate: Date, workTime: Double, overTime: Double) {
        self.id = UUID()
        self.startDate = startDate
        self.finishDate = finishDate
        self.workTime = workTime
        self.overTime = overTime
    }
}

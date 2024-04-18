//
//  Entry.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/2/23.
//

import Foundation

struct Entry: ChartableEntry {
    var id: UUID
    var startDate: Date
    var finishDate: Date
    var workTimeInSeconds: Int
    var overTimeInSeconds: Int
    var maximumOvertimeAllowedInSeconds: Int
    var standardWorktimeInSeconds: Int
    var grossPayPerMonth: Int
    var calculatedNetPay: Double?
    
    var overtimeFraction: CGFloat {
        CGFloat(overTimeInSeconds) / CGFloat(maximumOvertimeAllowedInSeconds)
    }
    var worktimeFraction: CGFloat {
        CGFloat(workTimeInSeconds) / CGFloat(standardWorktimeInSeconds)
    }
    
    init(startDate: Date,
         finishDate: Date,
         workTimeInSec: Int,
         overTimeInSec: Int,
         maximumOvertimeAllowedInSeconds: Int,
         standardWorktimeInSeconds: Int,
         grossPayPerMonth: Int,
         calculatedNetPay: Double?) {
        self.id = UUID()
        self.startDate = startDate
        self.finishDate = finishDate
        self.workTimeInSeconds = workTimeInSec
        self.overTimeInSeconds = overTimeInSec
        self.maximumOvertimeAllowedInSeconds = maximumOvertimeAllowedInSeconds
        self.standardWorktimeInSeconds = standardWorktimeInSeconds
        self.grossPayPerMonth = grossPayPerMonth
        self.calculatedNetPay = calculatedNetPay
    }
    
    ///Initialize with current date for start and finish, work time and overtime is set to 0
    init() {
        self.init(startDate: Date(), finishDate: Date(), workTimeInSec: 0, overTimeInSec: 0, maximumOvertimeAllowedInSeconds: 0, standardWorktimeInSeconds: 0, grossPayPerMonth: 0, calculatedNetPay: nil)
    }
}

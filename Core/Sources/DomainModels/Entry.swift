//
//  Entry.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/2/23.
//

import Foundation

public struct Entry: ChartableEntry {
    public var id: UUID
    public var startDate: Date
    public var finishDate: Date
    public var workTimeInSeconds: Int
    public var overTimeInSeconds: Int
    public var maximumOvertimeAllowedInSeconds: Int
    public var standardWorktimeInSeconds: Int
    public var grossPayPerMonth: Int
    public var calculatedNetPay: Double?
    
    public var overtimeFraction: CGFloat {
        CGFloat(overTimeInSeconds) / CGFloat(maximumOvertimeAllowedInSeconds)
    }
    public var worktimeFraction: CGFloat {
        CGFloat(workTimeInSeconds) / CGFloat(standardWorktimeInSeconds)
    }
    
    public init(startDate: Date,
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
    
    /// Initialize with current date for start and finish, work time and overtime is set to 0
    public init() {
        self.init(startDate: Date(),
                  finishDate: Date(),
                  workTimeInSec: 0,
                  overTimeInSec: 0,
                  maximumOvertimeAllowedInSeconds: 0,
                  standardWorktimeInSeconds: 0,
                  grossPayPerMonth: 0,
                  calculatedNetPay: nil)
    }
}

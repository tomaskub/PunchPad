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
    var workTimeInSeconds: Int
    var overTimeInSeconds: Int
    var maximumOvertimeAllowedInSeconds: Int
    var standardWorktimeAllowedInSeconds: Int
    var grossPayPerMonth: Int
    var calculatedNetPay: Int?
    
    init(startDate: Date, 
         finishDate: Date,
         workTimeInSec: Int,
         overTimeInSec: Int,
         maximumOvertimeAllowedInSeconds: Int,
         standardWorktimeAllowedInSeconds: Int,
         grossPayPerMonth: Int,
         calculatedNetPay: Int?) {
        self.id = UUID()
        self.startDate = startDate
        self.finishDate = finishDate
        self.workTimeInSeconds = workTimeInSec
        self.overTimeInSeconds = overTimeInSec
        self.maximumOvertimeAllowedInSeconds = maximumOvertimeAllowedInSeconds
        self.standardWorktimeAllowedInSeconds = standardWorktimeAllowedInSeconds
        self.grossPayPerMonth = grossPayPerMonth
        self.calculatedNetPay = calculatedNetPay
    }
    
    ///Initialize with current date for start and finish, work time and overtime is set to 0
    init() {
        self.init(startDate: Date(), finishDate: Date(), workTimeInSec: 0, overTimeInSec: 0, maximumOvertimeAllowedInSeconds: 0, standardWorktimeAllowedInSeconds: 0, grossPayPerMonth: 0, calculatedNetPay: nil)
    }
}

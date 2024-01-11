//
//  GrossSalary.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 06/01/2024.
//

import Foundation

struct GrossSalary {
    let period: Period
    let payPerHour: Double
    let payUpToDate: Double
    let payPredicted: Double?
    let numberOfWorkingDays: Int
    
    init(period: Period, payPerHour: Double, payUpToDate: Double, payPrediced: Double?, numberOfWorkingDays: Int) {
        self.period = period
        self.payPerHour = payPerHour
        self.payUpToDate = payUpToDate
        self.payPredicted = payPrediced
        self.numberOfWorkingDays = numberOfWorkingDays
    }
    
    init() {
        self.init(period: (Date(), Date()), payPerHour: 0, payUpToDate: 0, payPrediced: 0, numberOfWorkingDays: 0)
    }
}

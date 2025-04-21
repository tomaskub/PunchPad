//
//  GrossSalary.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 06/01/2024.
//

import Foundation

public struct GrossSalary {
    public let period: Period
    public let payPerHour: Double
    public let payUpToDate: Double
    public let payPredicted: Double?
    public let numberOfWorkingDays: Int
    
    public init(period: Period, payPerHour: Double, payUpToDate: Double, payPrediced: Double?, numberOfWorkingDays: Int) {
        self.period = period
        self.payPerHour = payPerHour
        self.payUpToDate = payUpToDate
        self.payPredicted = payPrediced
        self.numberOfWorkingDays = numberOfWorkingDays
    }
    
    public init() {
        self.init(period: (Date(), Date()), payPerHour: 0, payUpToDate: 0, payPrediced: 0, numberOfWorkingDays: 0)
    }
}

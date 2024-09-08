//
//  ChartPeriodServiceError.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 08/09/2024.
//

import Foundation

enum ChartPeriodServiceError: Error {
    case attemptedToRetrievePeriodForAll
    case failedToCreateStartDateFromComponents
    case failedToCreateDateByAddingComponents
    case failedToRetrieveChartTimeRangeCount
    case failedToRetriveDayComponentFromPeriod
}

//
//  ChartPeriodService.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 25/11/2023.
//

import Foundation

enum ChartPeriodServiceError: Error {
    case attemptedToRetrievePeriodForAll
    case failedToCreateStartDateFromComponents
    case failedToRetrieveChartTimeRangeCount
}

class ChartPeriodService {
    
    let calendar: Calendar
    
    init(calendar: Calendar) {
        self.calendar = calendar
    }
    
    /// Generate Period (touple of dates)  encompasing given time range, containing date
    /// - Parameters:
    ///     - calendar: the calendar used to establish the date periods (default calendar is .current)
    ///     - date: the date that the period contains
    ///     - timeRange:  time range that should be encompased in period
    /// - Throws: `ChartPeriodServiceError.failedToRetrieveChartTimeRangeCount` if calendar fails to calculate a range of days in time range, or `ChartPeriodServiceError.failedToCreateStartDateFromComponents` when attempt to create a start date from components.
    /// - Returns: a touple of start date and end date of the period
    func generatePeriod(for date: Date, in timeRange: ChartTimeRange) throws -> Period {
        var startDateComponents: DateComponents
        switch timeRange {
        case .week:
            startDateComponents = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
        case .month:
            startDateComponents = calendar.dateComponents([.month, .year], from: date)
        case .year:
            startDateComponents = calendar.dateComponents([.year], from: date)
        case .all:
            throw ChartPeriodServiceError.attemptedToRetrievePeriodForAll
        }
        guard let startDate = calendar.date(from: startDateComponents) else { throw  ChartPeriodServiceError.failedToCreateStartDateFromComponents }
        let numberOfDays = try getNumberOfDays(in: timeRange, for: date)
        let finishDate: Date = calendar.date(byAdding: .day, value: numberOfDays - 1, to: startDate)!
        return (startDate, finishDate)
    }
    
    func retardPeriod(with calendar: Calendar = .current, by timeRange: ChartTimeRange, from currentPeriod: Period) throws -> Period {
        let dateInPreviousPeriod = calendar.date(byAdding: .day, value: -1, to: currentPeriod.0)!
        let previousPeriod = try generatePeriod(for: dateInPreviousPeriod, in: timeRange)
        return previousPeriod
    }
    
    // not tested
    func advancePeriod(with calendar: Calendar = .current, by timeRange: ChartTimeRange, from currentPeriod: Period) throws -> Period {
        let numberOfDays = try getNumberOfDays(in: timeRange, for: currentPeriod.0)
        let newPeriodStartDate = calendar.date(byAdding: .day, value: numberOfDays, to: currentPeriod.0)!
        let newPeriodFinishDate = calendar.date(byAdding: .day, value: numberOfDays, to: currentPeriod.1)!
        return (newPeriodStartDate, newPeriodFinishDate)
    }
    
    /**
     Get a number of days in a given ChartTimeRange in which the given date exists
      - Parameters:
         - calendar: Calendar used to calculate ranges
         - timeRange: time range on which to calculate the number of days
         - date: date thats in time range
      - Throws: `ChartPeriodServiceError.failedToRetrieveChartTimeRangeCount` if calendar fails to calculate a range of days in time range,  or`ChartPeriodServiceError.attemptedToRetrievePeriodForAll` if time range is set to `.all`
      - Returns: number of days
     */
    private func getNumberOfDays(with calendar: Calendar = .current, in timeRange: ChartTimeRange, for date: Date) throws -> Int {
        switch timeRange {
        case .week:
            return 7
        case .month:
            guard let range = calendar.range(of: .day, in: .month, for: date) else {
                throw ChartPeriodServiceError.failedToRetrieveChartTimeRangeCount
            }
            return range.count
        case .year:
            guard let range = calendar.range(of: .day, in: .year, for: date) else {
                throw ChartPeriodServiceError.failedToRetrieveChartTimeRangeCount
            }
            return range.count
        case .all:
            guard let range = calendar.range(of: .day, in: .quarter, for: date) else {
                throw ChartPeriodServiceError.attemptedToRetrievePeriodForAll
            }
            return range.count
        }
    }
}


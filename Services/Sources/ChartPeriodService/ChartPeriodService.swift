//
//  ChartPeriodService.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 25/11/2023.
//

import ChartPeriodServiceInterfaces
import DomainModels
import Foundation
import FoundationExtensions
import OSLog

public class ChartPeriodService: ChartPeriodServicing {
    private let logger = Logger.chartService
    let calendar: Calendar
    
    public init(calendar: Calendar) {
        self.calendar = calendar
    }
    
    /// Generate Period (touple of dates)  encompasing given time range, containing date
    /// if calendar fails to calculate a range of days in time range,
    /// or `ChartPeriodServiceError.failedToCreateStartDateFromComponents`
    ///  when attempt to create a start date from components.
    /// - Parameters:
    ///     - calendar: the calendar used to establish the date periods (default calendar is .current)
    ///     - date: the date that the period contains
    ///     - timeRange:  time range that should be encompased in period
    /// - Throws: `ChartPeriodServiceError.failedToRetrieveChartTimeRangeCount`
    /// - Returns: a touple of start date and end date of the period
    public func generatePeriod(for date: Date, in timeRange: ChartTimeRange) throws -> Period {
        logger.debug("generatePeriod called in time range \(timeRange.description) for date: \(date)")
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
        guard let startDate = calendar.date(from: startDateComponents) else {
            throw  ChartPeriodServiceError.failedToCreateStartDateFromComponents
        }
        let numberOfDays = try getNumberOfDays(in: timeRange, for: date)
        guard let finishDate: Date = calendar.date(byAdding: .day, value: numberOfDays, to: startDate) else {
            throw ChartPeriodServiceError.failedToCreateDateByAddingComponents
        }
        return (startDate, finishDate)
    }
    
    public func generatePeriod(from startEntry: Entry, to finishEntry: Entry) throws -> Period {
        logger.debug("generatePeriod from entries")
        let startDate = calendar.startOfDay(for: startEntry.startDate)
        let startOfFinishEntryDay = calendar.startOfDay(for: finishEntry.finishDate)
        guard let finishDate = calendar.date(byAdding: .day, value: 1, to: startOfFinishEntryDay) else {
            throw ChartPeriodServiceError.failedToCreateDateByAddingComponents
        }
        return (startDate, finishDate)
    }
    
    public func retardPeriod(by timeRange: ChartTimeRange, from currentPeriod: Period) throws -> Period {
        logger.debug("retardPeriod called")
        guard let dateInPreviousPeriod = calendar.date(byAdding: .day, value: -1, to: currentPeriod.0) else {
            throw ChartPeriodServiceError.failedToCreateDateByAddingComponents
        }
        let previousPeriod = try generatePeriod(for: dateInPreviousPeriod, in: timeRange)
        return previousPeriod
    }
    
    public func advancePeriod(by timeRange: ChartTimeRange, from currentPeriod: Period) throws -> Period {
        logger.debug("advancePeriod called")
        guard let dateInNextPeriod = calendar.date(byAdding: .day, value: 1, to: currentPeriod.1) else {
            throw ChartPeriodServiceError.failedToCreateDateByAddingComponents
        }
        let nextPeriod = try generatePeriod(for: dateInNextPeriod, in: timeRange)
        return nextPeriod
    }
    
    public func returnPeriodMidDate(for period: Period) throws -> Date {
        logger.debug("returnPeriodMidDate called")
        guard let numberOfDays = calendar.dateComponents([.day], from: period.0, to: period.1).day else {
            throw ChartPeriodServiceError.failedToRetriveDayComponentFromPeriod
        }
        var dateComponents = calendar.dateComponents([.day, .month, .year], from: period.0)
        dateComponents.day! += numberOfDays/2
        return calendar.date(from: dateComponents)!
    }
    
    /// Get a number of days in a given ChartTimeRange in which the given date exists
    private func getNumberOfDays(in timeRange: ChartTimeRange, for date: Date) throws -> Int {
        logger.debug("getNumberOfDays called")
        let range: Range<Int>?
        switch timeRange {
        case .week:
            return 7
        case .month:
            range = calendar.range(of: .day, in: .month, for: date)
        case .year:
            range = calendar.range(of: .day, in: .year, for: date)
        case .all:
            throw ChartPeriodServiceError.attemptedToRetrievePeriodForAll
        }
        guard let range else {
            throw ChartPeriodServiceError.failedToRetrieveChartTimeRangeCount
        }
        return range.count
    }
}

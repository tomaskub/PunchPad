//
//  Calendar+Extension.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 21/12/2023.
//

import Foundation

extension Calendar.Component {
    
    /// A writable key path to date component property of Int? type, corresponsing with given calendar component
    /// If the keypath contains propety of diffferent type (like Bool), the var will return nil
    /// Not implemented calendar components will return nil as well.
    var dateComponentKeyPath: WritableKeyPath<DateComponents, Int?>? {
        switch self {
        case .era:
            return \.era
        case .year:
            return \.year
        case .month:
            return \.month
        case .day:
            return \.day
        case .hour:
            return \.hour
        case .minute:
            return \.minute
        case .second:
            return \.second
        case .weekday:
            return \.weekday
        case .weekdayOrdinal:
            return \.weekdayOrdinal
        case .quarter:
            return \.quarter
        case .weekOfMonth:
            return \.weekOfMonth
        case .weekOfYear:
            return \.weekOfYear
        case .yearForWeekOfYear:
            return \.yearForWeekOfYear
        case .nanosecond:
            return \.nanosecond
        case .calendar, .timeZone, .isLeapMonth:
            return nil
        @unknown default:
            return nil
        }
    }
}

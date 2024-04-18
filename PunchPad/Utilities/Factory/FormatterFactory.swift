//
//  FormatterFactory.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 21/12/2023.
//

import Foundation

struct FormatterFactory {
    /// Returns `DateComponentsFormatter` with hour and a minute components, positional unit style, and padd zero formatting behaviour
    static func makeHourAndMinuteDateComponentFormatter() -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }
    
    /// Returns `DateComponentsFormatter` with minute and second components, positional unit style, and padd zero formatting behaviour
    static func makeMinuteAndSecondDateComponetFormatter() -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }
    
    /// Returns `DateFormatter` with `dateStyle` set to `.none` and `timeStyle` set to `.short`
    static func makeTimeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
    
    /// Returns `DateFormatter` with `dateStyle` set to `.medium` and `timeStyle` set to `.none`
    static func makeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    /// Returns `DateFormatter` with date style displaying `23 Jun`, with no time components
    static func makeDayAndMonthDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter
    }
    
    /// Returns `DateFormatter` with date style displaying 3 letter month - `Jun`, with no time components
    static func makeMonthDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }
    
    /// Returns `DateFormatter` with date style displaying full month name - `January` and 4 digit year `1999`, with no time components
    static func makeFullMonthYearDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    /// Returns `DateFormatter` with date style displaying 4 digit year `1999`, with no time components
    static func makeYearDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }
    
    /// Returns `DateFormatter` with date style displaying 1 or 2 digit day of the month, with no time components
    static func makeDayDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }
    
    /// Returns `NumberFormatter` with given local and currency number style
    static func makeCurrencyFormatter(_ locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        return formatter
    }
}

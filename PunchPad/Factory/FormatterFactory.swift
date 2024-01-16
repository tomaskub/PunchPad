//
//  FormatterFactory.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 21/12/2023.
//

import Foundation

struct FormatterFactory {
    static func makeDateComponentFormatter() -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute]
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
    
    static func makeCurrencyFormatter(_ locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        return formatter
    }
}

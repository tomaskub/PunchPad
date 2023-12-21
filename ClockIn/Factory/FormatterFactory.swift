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
    
}

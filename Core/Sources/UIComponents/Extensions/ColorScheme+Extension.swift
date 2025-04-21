//
//  ColorScheme+Extension.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 14/09/2023.
//

import SwiftUI

public extension ColorScheme {
    
    var rawValue: String {
        switch self {
        case .light:
            return "light"
        case .dark:
            return "dark"
        @unknown default:
            fatalError()
        }
    }
    
    static func fromStringValue(_ value: String?) -> ColorScheme? {
        guard let unwrappedValue = value else { return nil }
        switch unwrappedValue {
        case "dark":
            return ColorScheme.dark
        case "light":
            return ColorScheme.light
        default:
            return nil
        }
    }
}

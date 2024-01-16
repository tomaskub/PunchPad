//
//  TabBarColorConfiguration.swift
//  TabViewKit
//
//  Created by Tomasz Kubiak on 16/01/2024.
//

import SwiftUI

/// Configuration model for custom tab bar - provides color properties for the custom tab bar view.
public struct TabBarColorConfiguration {
    let inactiveColor: Color
    let activeColor: Color
    let shadowColor: Color
    let backgroundColor: Color
    
    /// Create an instance of custom tab bar color configuration
    /// - Parameters:
    ///   - activeColor: color of the active tab bar item and its underline
    ///   - inactiveColor: color of the inactive tab bar items and underline of all of the items
    ///   - shadowColor: color of the shadow of the whole bar
    ///   - backgroundColor: background color of the whole bar
    public init(activeColor: Color,
                inactiveColor: Color,
                shadowColor: Color,
                backgroundColor: Color) {
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.shadowColor = shadowColor
        self.backgroundColor = backgroundColor
    }
    
    /// Private initializer with some colors used for previews inside of the module
    init() {
        self.activeColor = Color.green
        self.inactiveColor = Color.gray
        self.shadowColor = Color.black.opacity(0.3)
        self.backgroundColor = Color.white
    }
}

//
//  ColorScheme.swift
//  ThemeKit
//
//  Created by Tomasz Kubiak on 30/12/2023.
//

import SwiftUI

public struct ColorTheme {
    /// Green background color
    public let background = MyBundle.getColor("BackgroundColor")
    /// Semi-black color used for text in headings
    public let black = MyBundle.getColor("Black")
    /// Semi-black color used for text in labels
    public let blackLabel = MyBundle.getColor("BlackText")
    /// Timer button fill green color
    public let buttonColor = MyBundle.getColor("ButtonColor")
    /// Green color used for filling ring
    public let ringGreen = MyBundle.getColor("CircleRingGreen")
    /// White-gray color used for unfilled ring
    public let ringWhite = MyBundle.getColor("CircleRingUnfilled")
    /// Primary color used for buttons, labels and icons
    public let primary = MyBundle.getColor("Primary")
    /// Red color for chart  bars
    public let redChart = MyBundle.getColor("RedChart")
    /// Start color for ring red gradient
    public let redGradientStart = MyBundle.getColor("RedGradientStart")
    /// End color for ring red gradient
    public let redGradientEnd = MyBundle.getColor("RedGradientEnd")
    /// Red color used for timer label in overtime
    public let redLabel = MyBundle.getColor("RedLabel")
    /// Gray color used for timer label in worktime
    public let secondaryLabel = MyBundle.getColor("SecondaryWorktimeLabel")
    /// Gray opaque color used for background in segmented pickers
    public let tertiary = MyBundle.getColor("Tertiary")
    /// White color used for background elements of tab bars, list rows and navigation bars
    public let white = MyBundle.getColor("White")
    
    class MyBundle {
        static func generateBundleForSelf() -> Bundle {
            Bundle(for: self)
        }
        static func getColor(_ name: String) -> Color {
            Color(name, bundle: generateBundleForSelf())
        }
    }
}

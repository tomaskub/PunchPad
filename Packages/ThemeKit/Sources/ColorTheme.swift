//
//  ColorScheme.swift
//  ThemeKit
//
//  Created by Tomasz Kubiak on 30/12/2023.
//

import SwiftUI

public struct ColorTheme {
    /// Green background color
    public let background = Color("BackgroundColor", bundle: .module)
    /// Semi-black color used for text in headings
    public let black = Color("Black", bundle: .module)
    /// Semi-black color used for text in labels
    public let blackLabel = Color("BlackText", bundle: .module)
    /// Timer button fill green color
    public let buttonColor = Color("ButtonColor", bundle: .module)
    /// Green color used for filling ring
    public let ringGreen = Color("CircleRingGreen", bundle: .module)
    /// White-gray color used for unfilled ring
    public let ringWhite = Color("CircleRingUnfilled", bundle: .module)
    /// Primary color used for buttons, labels and icons
    public let primary = Color("Primary", bundle: .module)
    /// Red color for chart  bars
    public let redChart = Color("RedChart", bundle: .module)
    /// Start color for ring red gradient
    public let redGradientStart = Color("RedGradientStart", bundle: .module)
    /// End color for ring red gradient
    public let redGradientEnd = Color("RedGradientEnd", bundle: .module)
    /// Red color used for timer label in overtime
    public let redLabel = Color("RedLabel", bundle: .module)
    /// Gray color used for timer label in worktime
    public let secondaryLabel = Color("SecondaryWorktimeLabel", bundle: .module)
    /// Gray opaque color used for background in segmented pickers
    public let tertiary = Color("Tertiary", bundle: .module)
    /// White color used for background elements of tab bars, list rows and navigation bars
    public let white = Color("White", bundle: .module)
    /// Dark gray color used for dismissive button label
    public let buttonLabelGray = Color("ButtonLabelGray", bundle: .module)
}

public struct Logo {
    public static func logo() -> Image {
        return Image("Logo", bundle: .module)//MyBundle.generateBundleForSelf())
    }
}

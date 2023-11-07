//
//  ColorTheme.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 07/11/2023.
//

import SwiftUI

extension Color {
    static let theme: ColorTheme = ColorTheme()
}

struct ColorTheme {
    let accent = Color("GreenColorScheme/AccentColor")
    let background = Color("GreenColorScheme/BackgroundColor")
    let darkGreen = Color("GreenColorScheme/DarkGreen")
    let lightGreen = Color("GreenColorScheme/LightGreen")
    let mutedGreen = Color("GreenColorScheme/MutedGreen")
}

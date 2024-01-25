//
//  NavBarBackButtonColorPrefKey.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 25/01/2024.
//

import SwiftUI

public struct NavBarBackButtonColorPrefKey: PreferenceKey {
    static public var defaultValue: Color = .primary
    public static func reduce(value: inout Color, nextValue: () -> Color) {
        value = nextValue()
    }
}

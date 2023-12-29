//
//  NavBarTrailingPrefKey.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

public struct NavBarTrailingPrefKey: PreferenceKey {
    static public var defaultValue: EquatableView = .init()
    
    public static func reduce(value: inout EquatableView, nextValue: () -> EquatableView) {
        value = nextValue()
    }
}

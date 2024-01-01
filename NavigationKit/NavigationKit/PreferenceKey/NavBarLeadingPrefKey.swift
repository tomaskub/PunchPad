//
//  NavBarLeadingPrefKey.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

public struct NavBarLeadingPrefKey: PreferenceKey {
    static public var defaultValue: _EquatableView = _EquatableView.defaultView
    
    public static func reduce(value: inout _EquatableView, nextValue: () -> _EquatableView) {
        value = nextValue() == defaultValue ? value : nextValue()
    }
}

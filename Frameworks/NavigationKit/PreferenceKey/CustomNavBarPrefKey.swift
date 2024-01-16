//
//  CustomNavBarPrefKey.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

public struct CustomNavBarPrefKey: PreferenceKey {
    static public var defaultValue: _EquatableView = .init()
    
    public static func reduce(value: inout _EquatableView, nextValue: () -> _EquatableView) {
        value = nextValue()
    }
}

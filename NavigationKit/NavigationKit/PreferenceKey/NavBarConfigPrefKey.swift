//
//  NavBarConfigPrefKey.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

public struct NavBarConfigPrefKey: PreferenceKey {
    static public var defaultValue: NavBarTitleConfiguration = .init(title: "", textColor: .primary, alignment: .center)
    
    public static func reduce(value: inout NavBarTitleConfiguration, nextValue: () -> NavBarTitleConfiguration) {
        value = nextValue()
    }
}

//
//  CustomNavigationDisplayTypePreferenceKey.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 28/12/2023.
//

import SwiftUI

struct CustomNavigationDisplayTypePreferenceKey: PreferenceKey {
    static var defaultValue: NavigationBarItem.TitleDisplayMode = .automatic
    static func reduce(value: inout NavigationBarItem.TitleDisplayMode, nextValue: () -> NavigationBarItem.TitleDisplayMode) {
        value = nextValue()
    }
}

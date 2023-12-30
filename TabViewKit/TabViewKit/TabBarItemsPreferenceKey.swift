//
//  TabBarItemsPreferenceKey.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 28/12/2023.
//

import SwiftUI

struct TabBarItemsPreferenceKey: PreferenceKey {
    static var defaultValue: [TabBarItem] = []
    
    static func reduce(value: inout [TabBarItem], nextValue: () -> [TabBarItem]) {
        value += nextValue()
    }
}

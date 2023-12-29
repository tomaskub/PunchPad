//
//  NavBarScrollingPrefKey.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

public struct NavBarScrollingPrefKey: PreferenceKey {
    static public var defaultValue: Bool = false
    
    public static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

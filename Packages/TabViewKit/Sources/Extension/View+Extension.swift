//
//  View+Extension.swift
//  TabViewKit
//
//  Created by Tomasz Kubiak on 30/12/2023.
//

import SwiftUI

public extension View {
    /// A modifier used to register a tabBarItem in CustomTabBarContainerView
    /// - Parameters:
    ///     - tab: A tab bar item used to represent the tab
    ///     - selection: Reference to binding value for container view
    func tabBarItem(tab: TabBarItem, selection: Binding<TabBarItem>) -> some View {
        self.modifier(TabBarItemViewModifier(selection: selection, tab: tab))
    }
}

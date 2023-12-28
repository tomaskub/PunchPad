//
//  View+Extension.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 15/11/2023.
//

import SwiftUI

extension View {
    /// Applies given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///     - condition: The condition to evaluate.
    ///     - transform: The transform to apply to the source `View`.
    /// - Returns: Modified `View` or original `View`
    @ViewBuilder
    func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
    /// Applies given transform if the given value is not `nil`.
    /// - Parameters:
    ///     - value: The parameter to check for `nil` value
    ///     - transform: The transform to apply to the source `View` with unwrapped `value`.
    /// - Returns: Modified `View` or original `View`
    @ViewBuilder
    func ifLet<V, Transform: View>(_ value: V?, transform: (Self, V) -> Transform) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
    
    func emptyPlaceholder<Items: Collection, PlaceholderView: View>(_ items: Items, _ placeholder: @escaping () -> PlaceholderView) -> some View {
        self.modifier(
            EmptyPlaceholderModifier(items: items,
                                     placeholder: AnyView(placeholder())
                                    )
        )
    }
    /// A modifier used to register a tabBarItem in CustomTabBarContainerView
    /// - Parameters:
    ///     - tab: A tab bar item used to represent the tab
    ///     - selection: Reference to binding value for container view
    func tabBarItem(tab: TabBarItem, selection: Binding<TabBarItem>) -> some View {
        self.modifier(TabBarItemViewModifier(selection: selection, tab: tab))
    }
    /// Add a preference for CustomNavigationBar title property
    /// - Parameter title: title value to set
    func customNavigationTitle(_ title: String) -> some View {
        self.preference(key: CustomNavigationBarTitlePreferenceKey.self,
                        value: title)
    }
    /// Add preference for CustomNavigationBar subtitle
    /// - Parameter subtitle: subtitle value to set
    func customNavigationSubtitle(_ subtitle: String?) -> some View {
        self.preference(key: CustomNavigationBarSubtitlePreferenceKey.self,
                        value: subtitle)
    }
    /// Add preference for CustomNavigationBar back button presence
    /// - Parameter hidden: Bool value controling presence of back button
    func customNavigationBarBackButtonHidden(_ hidden: Bool) -> some View {
        self.preference(key: CustomNavigationBarBackButtonHiddenPreferenceKey.self,
                        value: hidden)
    }
    /// Add preference for CustomNavigationBar display mode
    /// - Parameter displayMode: display mode for the Bar when view is presented
    func customNavigationBarDisplayType(_ displayMode: NavigationBarItem.TitleDisplayMode) -> some View {
        self.preference(key: CustomNavigationDisplayTypePreferenceKey.self, value: displayMode)
    }
    
    /// Add preference keys used by CustomNavigationBar for view
    /// - Parameters:
    ///   - title: title value displayed by CustomNavigationBa
    ///   - subtitle: subtitle value displayed by CustomNavigationBa
    ///   - backButtonHidden: value controling present of back button by CustomNavigationBa
    ///   - displayType: display mode for CustomNavigationBa
    func customNavigationBarItems(title: String,
                                  subtitle: String? = nil,
                                  backButtonHidden: Bool = false,
                                  displayType: NavigationBarItem.TitleDisplayMode = .automatic) -> some View {
        self.customNavigationTitle(title)
            .customNavigationSubtitle(subtitle)
            .customNavigationBarBackButtonHidden(backButtonHidden)
            .customNavigationBarDisplayType(displayType)
    }
}


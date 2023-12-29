//
//  View+Extension.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

public extension View {
     /// Hides the navigation bar.
    /// - Returns: A modified view with the navigation bar hidden.
    func hideNavigationBar() -> some View {
        self
            .preference(key: NavBarHiddenPrefKey.self, value: true)
    }
    
    /// Sets the title, alignment, text color, and typography for the navigation bar.
    /// - Parameters:
    ///   - title: The title of the navigation bar.
    ///   - alignment: The alignment of the title (default is `.leading`).
    ///   - textColor: The text color of the title (default is `.Brand.N900`).
    ///   - typography: The typography style of the title (default is `.heading_4`).
    /// - Returns: A modified view with the specified navigation bar title configuration.
    func navigationBarTitle(_ title: String, alignmet: Alignment = .leading, textColor: Color = .primary) -> some View {
        self
            .preference(key: NavBarConfigPrefKey.self, value: .init(title: title, textColor: textColor, alignment: alignmet))
    }
    
    /// Sets the background view for the navigation bar.
    /// - Parameter bg: A closure returning the background view.
    /// - Returns: A modified view with the specified navigation bar background.
    func navigationBarBackground<B: View>(@ViewBuilder bg:  @escaping () -> B) -> some View {
        self
            .preference(key: NavBarBackgroundPrefKey.self, value: .init(view: AnyView(bg())))
    }
    
    /// Sets the leading item view for the navigation bar.
    /// - Parameter content: A closure returning the leading item view.
    /// - Returns: A modified view with the specified navigation bar leading item.
    func navigationBarLeadingItem<L: View>(@ViewBuilder content:  @escaping () -> L) -> some View {
        self
            .preference(key: NavBarLeadingPrefKey.self, value: .init(view: AnyView(content())))
    }
    
    /// Sets the trailing item view for the navigation bar.
    /// - Parameter content: A closure returning the trailing item view.
    /// - Returns: A modified view with the specified navigation bar trailing item.
    func navigationBarTrailingItem<L: View>(@ViewBuilder content:  @escaping () -> L) -> some View {
        self
            .preference(key: NavBarTrailingPrefKey.self, value: .init(view: AnyView(content())))
    }
    
    /// Sets both leading and trailing item views for the navigation bar.
    /// - Parameters:
    ///   - leading: A closure returning the leading item view.
    ///   - trailing: A closure returning the trailing item view.
    /// - Returns: A modified view with the specified navigation bar leading and trailing items.
    func navigationBarItems<L: View, T: View>(@ViewBuilder leading:  @escaping () -> L, @ViewBuilder trailing:  @escaping () -> T) -> some View {
        self
            .preference(key: NavBarTrailingPrefKey.self, value: .init(view: AnyView(trailing())))
            .preference(key: NavBarLeadingPrefKey.self, value: .init(view: AnyView(leading())))
    }
    
    /// Sets a custom content view for the navigation bar.
    /// - Parameter content: A closure returning the custom content view.
    /// - Returns: A modified view with the specified custom navigation bar content.
    func navigationBar<Content: View>(@ViewBuilder _ content: @escaping () -> Content) -> some View {
        self
            .hideNavigationBar()
            .preference(key: CustomNavBarPrefKey.self, value: .init(view: AnyView(content())))
    }
    
    /// Sets the scrolling status for the navigation bar.
    /// - Parameter hasScrolled: A boolean indicating whether the view is currently scrolling.
    /// - Returns: A modified view with the specified scrolling status.
    func _hasScrolledDownward(_ hasScrolled: Bool) -> some View {
        self
            .preference(key: NavBarScrollingPrefKey.self, value: hasScrolled)
    }
}

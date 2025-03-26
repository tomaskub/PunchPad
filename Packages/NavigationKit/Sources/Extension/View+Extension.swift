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
}

// MARK: NAVIGATION BAR TITLE
public extension View {
    /// Sets the title, alignment, text color, and typography for the navigation bar.
    /// - Parameters:
    ///   - title: The title of the navigation bar.
    ///   - alignment: The alignment of the title (default is `.leading`).
    ///   - textColor: The text color of the title (default is `.primary`).
    /// - Returns: A modified view with the specified navigation bar title configuration.
    func navigationBarTitle(_ title: String, alignmet: Alignment = .leading, textColor: Color = .primary) -> some View {
        self
            .preference(key: NavBarConfigPrefKey.self, value: .init(title: title, textColor: textColor, alignment: alignmet))
    }
    
    /// Sets the title and alignment for the navigation bar
    /// - Parameters:
    ///   - title: Attributed title of the navigation bar
    ///   - alignment: The alignment of the title (default is `.leading`)
    /// - Returns: A modified view with the specified navigation bar title configuration
    func navigationBarTitle(_ title: AttributedString, alignment: Alignment = .leading) -> some View {
        self
            .preference(key: NavBarConfigPrefKey.self, value: .init(title: title, alignment: alignment))
    }
    
    /// Set the configuration for the navigation bar
    /// - Parameter config: Config of the navigation bar
    /// - Returns: A modified view with the specified navigation bar title configuration
    func navigationBarTitle(config: NavBarTitleConfiguration) -> some View {
        self
            .preference(key: NavBarConfigPrefKey.self, value: config)
    }
    
    /// Set the color of back button for the navigation bar
    /// - Parameter color: Foreground color of the navigation bar
    /// - Returns: A modified view with the specified navigation bar back button color
    func navigationBarBackButtonColor(color: Color) -> some View {
        self
            .preference(key: NavBarBackButtonColorPrefKey.self, value: color)
    }
}

// MARK: NAVIGATION BAR BACKGROUND
public extension View {
    /// Sets the background view for the navigation bar.
    /// - Parameter bg: A closure returning the background view.
    /// - Returns: A modified view with the specified navigation bar background.
    func navigationBarBackground<B: View>(@ViewBuilder bg:  @escaping () -> B) -> some View {
        self
            .preference(key: NavBarBackgroundPrefKey.self, value: .init(view: AnyView(bg())))
    }
    
    func navigationBarBackground(bg: AnyView) -> some View {
        self
            .preference(key: NavBarBackgroundPrefKey.self, value: .init(view: bg))
    }
}

// MARK: NAVIGATION BAR LEADING & TRAILING ITEM
public extension View {
    /// Sets the leading item view for the navigation bar.
    /// - Parameter content: A closure returning the leading item view.
    /// - Returns: A modified view with the specified navigation bar leading item.
    func navigationBarLeadingItem<L: View>(@ViewBuilder content:  @escaping () -> L) -> some View {
        self
            .preference(key: NavBarLeadingPrefKey.self, value: .init(view: AnyView(content())))
    }
    
    func navigationBarLeadingItem(content: AnyView) -> some View {
        self
            .preference(key: NavBarLeadingPrefKey.self, value: .init(view: content))
    }
    
    /// Sets the trailing item view for the navigation bar.
    /// - Parameter content: A closure returning the trailing item view.
    /// - Returns: A modified view with the specified navigation bar trailing item.
    func navigationBarTrailingItem<L: View>(@ViewBuilder content:  @escaping () -> L) -> some View {
        self
            .preference(key: NavBarTrailingPrefKey.self, value: .init(view: AnyView(content())))
    }
    
    func navigationBarTrailingItem(content: AnyView) -> some View {
        self
            .preference(key: NavBarTrailingPrefKey.self, value: .init(view: content))
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
}

// MARK: NAVIGATION BAR CONTENT
public extension View {
    /// Sets a custom content view for the navigation bar.
    /// - Parameter content: A closure returning the custom content view.
    /// - Returns: A modified view with the specified custom navigation bar content.
    func navigationBar<Content: View>(@ViewBuilder _ content: @escaping () -> Content) -> some View {
        self
            .hideNavigationBar()
            .preference(key: CustomNavBarPrefKey.self, value: .init(view: AnyView(content())))
    }
    /// Sets a custom content view for the navigation bar.
    /// - Parameter content: An AnyView wrapped content view.
    /// - Returns: A modified view with the specified custom navigation bar content.
    func navigationBar(_ content: AnyView) -> some View {
        self
            .hideNavigationBar()
            .preference(key: CustomNavBarPrefKey.self, value: .init(view: content))
    }
    
    /// Sets the scrolling status for the navigation bar.
    /// - Parameter hasScrolled: A boolean indicating whether the view is currently scrolling.
    /// - Returns: A modified view with the specified scrolling status.
    func _hasScrolledDownward(_ hasScrolled: Bool) -> some View {
        self
            .preference(key: NavBarScrollingPrefKey.self, value: hasScrolled)
    }
    
    func isNavigationBarHidden(_ value: Bool) -> some View {
        self.preference(key: NavBarHiddenPrefKey.self, value: value)
    }
    
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
}

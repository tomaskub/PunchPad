//
//  ViewController.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import UIKit
import SwiftUI

@MainActor open class ViewController: UIViewController {
    private let config = NavigationBarConfiguration()
    
    /// Configuration for the navigation bar title. Updates will be published to `navBarConfigurationPublisher`.
    final public var navBarTitleConfiguration = NavBarTitleConfiguration(title: "") {
        didSet {
            config.state.navConfig = navBarTitleConfiguration
        }
    }
    
    /// Determines whether the navigation bar is hidden. Updates will be published to `navBarConfigurationPublisher`.
    final public var isNavigationBarHidden = false {
        didSet {
            config.state.isNavBarHidden = isNavigationBarHidden
        }
    }
    
    /// Sets the leading item of the navigation bar.
    /// - Parameter content: A closure returning the leading item view.
    final public func setNavBarLeadingItem<Content: View>(@ViewBuilder content: () -> Content) {
        config.state.leadingItem = .init(content())
    }
    
    /// Sets the trailing item of the navigation bar.
    /// - Parameter content: A closure returning the trailing item view.
    final public func setNavBarTrailingItem<Content: View>(@ViewBuilder content: () -> Content) {
        config.state.trailingView = .init(content())
    }
    
    /// Sets the background view for the navigation bar.
    /// - Parameter content: A closure returning the background view.
    final public func setNavBarBackground<Content: View>(@ViewBuilder content: () -> Content) {
        config.state.navBarBackgroundView = .init(content())
    }
    
    /// Sets a custom view for the navigation bar.
    /// - Parameter content: A closure returning the custom navigation bar view.
    final public func setCustomNavBar<Content: View>(@ViewBuilder content: () -> Content) {
        config.state.customNavBar = .init(content())
    }
    
    /// A SwiftUI view representation of the view controller.
    @ViewBuilder final public func toSwiftUIView() -> some View  {
        _SwiftUIView(navConfig: config, vc: self)
    }
}



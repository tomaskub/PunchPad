//
//  NavigationBarWrapper.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

/// NavigationBarWrapperView is a wrapper around CustomNavigationBarView. It provides default configuration for CustomNavigationBar, listens to preference changes, and updates the CustomNavigationBarView with registered changes.
struct NavigationBarWrapper<Content: View>: View {
    
    // Determines if a back button should be shown in the navigation bar.
    let showBackButton: Bool
    
    // The destination content view that this navigation bar is associated with.
    @ViewBuilder let destination: () -> Content
    
    // Action to perform when the back button is tapped.
    let onBackTapped: () -> Void
    
    // Configuration for the navigation bar title.
    @State private var navConfig = NavBarTitleConfiguration(title: "")
    
    // Custom background view for the navigation bar.
    @State private var backgroundView = EquatableView()
    
    // Custom leading elements (e.g., buttons, icons) in the navigation bar.
    @State private var leadingView = EquatableView()
    
    // Custom trailing elements in the navigation bar.
    @State private var trailingView = EquatableView()
    
    // Allows for a custom navigation bar to be set.
    @State private var customNavBar: EquatableView?
    
    // Indicates whether the content is being scrolled.
    @State private var isScrolling = false
    
    // Controls the visibility of the navigation bar.
    @State private var isNavBarHidden = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Check if the navigation bar is hidden and display content accordingly
            if isNavBarHidden {
                // Display custom navigation bar if it is hidden
                customNavBar?.view
            } else {
                // Custom navigation bar component with configurable elements
                CustomNavigationBarView(
                    config: navConfig,
                    shouldShowBackButton: showBackButton,
                    background: backgroundView,
                    leadingElements: leadingView,
                    trailingElements: trailingView,
                    shouldElevate: isScrolling,
                    onBackTapped: onBackTapped)
            }
            // Main content view
            destination()
                .frame(maxHeight: .infinity)
        }
        .onPreferenceChange(NavBarConfigPrefKey.self) { config in
            self.navConfig = config
        }
        .onPreferenceChange(NavBarBackgroundPrefKey.self) { bg in
            self.backgroundView = bg
        }
        .onPreferenceChange(NavBarLeadingPrefKey.self) { leadingView in
            self.leadingView = leadingView
        }
        .onPreferenceChange(NavBarTrailingPrefKey.self) { trailingView in
            self.trailingView = trailingView
        }
        .onPreferenceChange(NavBarScrollingPrefKey.self) { isScrolling in
            withAnimation {
                self.isScrolling = isScrolling
            }
        }
        .onPreferenceChange(NavBarHiddenPrefKey.self) { isNavBarHidden in
            self.isNavBarHidden = isNavBarHidden
        }
        .onPreferenceChange(CustomNavBarPrefKey.self) { navBar in
            self.customNavBar = navBar
        }
    }
}

#Preview {
    NavigationBarWrapper(showBackButton: false) {
        Color.red
            .frame(width: 100, height: 100)
            .overlay {
                Text("Destination")
                    .foregroundColor(.white)
            }
            .navigationBarTitle("Sample wrapper view")
    } onBackTapped: {
        print("Back tapped")
    }
}

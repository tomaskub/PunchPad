//
//  NavHost.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

public struct NavHost<Content: View, Route: Equatable>: View {
    private let navigator: Navigator<Route>
    @ViewBuilder private let destinationBuilder: @MainActor @Sendable (Route) -> Content
    
    public init(navigator: Navigator<Route>, @ViewBuilder destinationBuilder: @MainActor @Sendable @escaping (Route) -> Content) {
        self.navigator = navigator
        self.destinationBuilder = destinationBuilder
    }
    
    public var body: some View {
        _NavigationControllerWrapper(
            navigator: navigator,
            destinationBuilder: destinationBuilder)
        .edgesIgnoringSafeArea(.all)
    }
}

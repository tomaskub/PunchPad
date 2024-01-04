//
//  NavigatorDelegate.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import Foundation

struct NavigatorDelegate<Route: Equatable> {
    var push: (_ route: Route, _ animate: Bool) -> Void
    var popToCountFromLast: (_ count: Int) -> Void
    var present: (_ route: Route, _ isFullScreen: Bool, _ animate: Bool, _ completion: (() -> Void)?)  -> Void
    var dismiss: (_ animated : Bool, _ completion: (() -> Void)?)  -> Void
}

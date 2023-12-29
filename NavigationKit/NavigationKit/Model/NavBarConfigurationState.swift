//
//  NavBarConfigurationState.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

struct NavBarConfigurationState {
    var navConfig = NavBarTitleConfiguration(title: "")
    var isNavBarHidden = false
    var leadingItem: AnyView?
    var trailingView: AnyView?
    var navBarBackgroundView: AnyView?
    var customNavBar: AnyView?
}

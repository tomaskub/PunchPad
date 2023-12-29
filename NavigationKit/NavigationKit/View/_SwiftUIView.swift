//
//  _SwiftUIView.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

struct _SwiftUIView: View {
    @ObservedObject var navConfig: NavigationBarConfiguration
    let vc: ViewController
    
    var body: some View {
        return ViewControllerRepresentable(vc: vc)
            .navigationBarTitle(config: navConfig.state.navConfig)
        //Below is original implementation that was not explained in source, it for replaced with hideNavigationBar, an implementation was written that sets the value of state
            .isNavigationBarHidden(navConfig.state.isNavBarHidden)
            .if(navConfig.state.leadingItem != nil) {
                $0
                    .navigationBarLeadingItem(content: navConfig.state.leadingItem!)
            }
            .if(navConfig.state.trailingView != nil) {
                $0
                    .navigationBarTrailingItem(content: navConfig.state.trailingView!)
            }
            .if(navConfig.state.navBarBackgroundView != nil) {
                $0
                    .navigationBarBackground(bg: navConfig.state.navBarBackgroundView!)
            }
            .if(navConfig.state.customNavBar != nil) {
                $0
                    .navigationBar({ navConfig.state.customNavBar! })
            }
    }
}

#Preview {
    _SwiftUIView()
}

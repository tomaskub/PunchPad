//
//  CustomNavigationBar.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

struct CustomNavigationBarView: View {
    let config: NavBarTitleConfiguration
    let shouldShowBackButton: Bool
    let background: EquatableView
    let leadingElements: EquatableView
    let trailingElements: EquatableView
    let shouldElevate: Bool
    let onBackTapped: () -> Void
    
    var body: some View {
        //Custom implementation of the appearance of the bar
        HStack {
            leadingElements.view
            Spacer()
            Text(config.title)
                .foregroundColor(config.textColor)
            Spacer()
            trailingElements.view
        }
    }
}

#Preview {
    CustomNavigationBarView(config: NavBarTitleConfiguration(title: "Preview",
                                                         textColor: .black,
                                                         alignment: .center),
                        shouldShowBackButton: true,
                        background: .init(view: AnyView(Color.blue)),
                        leadingElements: .init(view: AnyView(Image(systemName: "plus"))),
                        trailingElements: .init(view: AnyView(Image(systemName:"heart.fill"))),
                        shouldElevate: false) {
        print("back tapped")
    }
}

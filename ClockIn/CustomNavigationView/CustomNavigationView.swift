//
//  CustomNavigationView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 28/12/2023.
//

import SwiftUI

struct CustomNavigationView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationView{
            CustomNavigationContainerView {
                content
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview("CustomNavigationView") {
    struct Preview: View {
        var body: some View {
            CustomNavigationView {
                ZStack {
                    Color.orange
                    CustomNavigationLink(destination:
                                            Text("Destination").customNavigationBarBackButtonHidden(false),
                                         label: {
                        Text("Run navigate")
                    })
                }
                .customNavigationBarItems(title: "Custom navigation", subtitle: "Preview subtitle", backButtonHidden: true)
            }
        }
    }
    return Preview()
}



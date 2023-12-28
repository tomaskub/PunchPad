//
//  CustomNavigationContainerView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 28/12/2023.
//

import SwiftUI

struct CustomNavigationContainerView<Content: View>: View {
    @State private var showBackButton: Bool = true
    @State private var title: String = ""
    @State private var subtitle: String? = nil
    @State private var displayType: NavigationBarItem.TitleDisplayMode = .automatic
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        VStack(spacing: 0) {
                CustomNavigationBarView(showBackButton: showBackButton, title: title, subtitle: subtitle)
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        .onPreferenceChange(CustomNavigationBarTitlePreferenceKey.self, perform: { value in
            self.title = value
        })
        .onPreferenceChange(CustomNavigationBarSubtitlePreferenceKey.self, perform: { value in
            self.subtitle = value
        })
        .onPreferenceChange(CustomNavigationBarBackButtonHiddenPreferenceKey.self, perform: { value in
            self.showBackButton = !value
        })
        .onPreferenceChange(CustomNavigationDisplayTypePreferenceKey.self, perform: { value in
            self.displayType = value
        })
        
        
    }
}

#Preview {
    struct Preview: View {
        var body: some View {
            CustomNavigationContainerView {
                ZStack {
                    BackgroundFactory.buildSolidColor()
                    
                    NavigationLink {
                        Text("Destination")
                    } label: {
                        Text("Navigate")
                    }
                    
                }
                .customNavigationTitle("Title")
                .customNavigationSubtitle("Subtitle")
                .customNavigationBarBackButtonHidden(false)
                .customNavigationBarDisplayType(.inline)
            }
            
        }
    }
    return Preview()
}

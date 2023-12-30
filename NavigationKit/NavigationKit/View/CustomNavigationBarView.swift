//
//  CustomNavigationBar.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

struct CustomNavigationBarView: View {
    @State private var barItemsWidth: CGFloat = 0
    let config: NavBarTitleConfiguration
    let shouldShowBackButton: Bool
    let background: EquatableView
    let leadingElements: EquatableView
    let trailingElements: EquatableView
    let shouldElevate: Bool
    let onBackTapped: () -> Void
    
    let size: CGFloat = 80
    let inlineSize: CGFloat = 40
    
    var body: some View {
        HStack {
            leadingElements.view
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: BarItemPrefKey.self, value: proxy.size.width)
                    }
                )
                .frame(width: barItemsWidth,
                       alignment: .leading
                )
            
            NavigationBarTitleView(title: config.title,
                                   color: config.textColor,
                                   font: config.font
            )
            .frame(maxWidth: .infinity, 
                   maxHeight: shouldElevate ? inlineSize : size,
                   alignment: config.alignment
            )
            
            trailingElements.view
                .background(
                    GeometryReader { proxy in
                    Color.clear
                            .preference(key: BarItemPrefKey.self, value: proxy.size.width)
                }
                )
                .frame(width: barItemsWidth, alignment: .trailing)
        }
        .onPreferenceChange(BarItemPrefKey.self) { value in
            barItemsWidth = value
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, shouldElevate ? 24 : 16)
        .background {
            background.view
        }
    }
}

private extension CustomNavigationBarView {
    struct BarItemPrefKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}
struct NavigationBarTitleView: View {
    let title: String
    let color: Color
    let font: Font
    
    var body: some View {
            Text(title)
                .foregroundColor(color)
                .font(font)
    }
    
}
#Preview {
    struct Preview: View {
        let navBarTitleConfiguration = NavBarTitleConfiguration(title: "Preview",
                                                                textColor: .black,
                                                                font: .body,
                                                                alignment: .center)
        var navBarBackground: some View {
            RoundedRectangle(cornerRadius: 24)
                .foregroundColor(.white)
                .ignoresSafeArea(edges: .top)
                .shadow(color: .black.opacity(0.2), radius: 12, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 4)
        }
        
        var leadingElements: some View {
            HStack{
                Label("Back", systemImage: "chevron.left")
                    .fixedSize()
                    .foregroundColor(.blue)
                Image(systemName: "plus")
            }
        }
        
        var trailingElements: some View {
            Image(systemName:"gearshape.fill")
                .foregroundColor(.green.opacity(0.5))
        }
        
        var background: some View {
            Color.green.opacity(0.2)
                .ignoresSafeArea()
        }
        var body: some View {
            VStack{
                CustomNavigationBarView(config: navBarTitleConfiguration,
                                        shouldShowBackButton: true,
                                        background: .init(view: AnyView(navBarBackground)),
                                        leadingElements: .init(view: AnyView(leadingElements)),
                                        trailingElements: .init(view: AnyView(trailingElements)),
                                        shouldElevate: true) { print("back tapped") }
                Spacer()
            }
            .background { background }
        }
    }
    return Preview()
}

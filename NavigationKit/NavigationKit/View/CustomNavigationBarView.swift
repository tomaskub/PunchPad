//
//  CustomNavigationBar.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI
import ThemeKit

struct CustomNavigationBarView: View {
    @State private var barItemsWidth: CGFloat = 0
    let config: NavBarTitleConfiguration
    let shouldShowBackButton: Bool
    let background: _EquatableView
    let leadingElements: _EquatableView
    let trailingElements: _EquatableView
    let shouldElevate: Bool
    let onBackTapped: () -> Void
    
    var body: some View {
        switch shouldElevate {
        case true:
            reducedSizeBar
        case false:
            fullSizeBar
        }
    }
    
    var reducedSizeBar: some View {
        HStack {
            Group {
                if shouldShowBackButton {
                    backButton
                } else {
                    backButton.opacity(0)
                }
                leadingElements.view
                    .font(.headline)
            }
            .frame(width: barItemsWidth)
            .background(makeWidthReader())
            
            Text(config.title)
                .font(.headline)
                .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            
            trailingElements.view
                .font(.headline)
                .frame(width: barItemsWidth)
                .background(makeWidthReader())
        }
        .frame(height: 20)
        .padding(.bottom, 14)
        .onPreferenceChange(BarItemWidthPrefKey.self) { value in
            barItemsWidth = value
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 30)
        .background {
            background.view
        }
    }
    
    var fullSizeBar: some View {
        VStack(alignment: .leading, spacing: 0) {
            if shouldShowBackButton {
                backButton
            } else {
                backButton.opacity(0) // this hides back button but it still is tappable? do not know if it will create a problem?
            }
            HStack {
                leadingElements.view
                    .font(.title)
                    .background(makeWidthReader())
                
                Text(config.title)
                
                Spacer()
                
                trailingElements.view
                    .font(.title)
                    .background(makeWidthReader())
            }
            .frame(height: 40)
            .padding(.bottom, 8)
            .onPreferenceChange(BarItemWidthPrefKey.self) { value in
                barItemsWidth = value
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 30)
        .background {
            background.view
        }
    }
    
    var backButton: some View {
        HStack {
            Image(systemName: "chevron.left")
            Text("Back")
        }
        .font(.system(size: 16))
        .foregroundColor(Color.theme.primary)
        .onTapGesture {
            onBackTapped()
        }
    }
}

//MARK: WIDTH AND HEIGHT ADJUSTMENTS
private extension CustomNavigationBarView {
    struct BarItemWidthPrefKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    
    struct BarHeightPrefKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    
    @ViewBuilder
    private func makeWidthReader() -> some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: BarItemWidthPrefKey.self, value: proxy.size.width)
        }
    }
    
    @ViewBuilder
    private func makeHeightReader() -> some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: BarHeightPrefKey.self, value: proxy.size.height)
        }
    }
}

//MARK: PREVIEWS
#Preview("Home configuration") {
    struct Preview: View {
        let navBarTitleConfiguration = {
            var title = AttributedString("PunchPad")
            title.font = .system(size: 32)
            if let range = title.range(of: "Punch") {
                title[range].font = .system(size: 32, weight: .bold)
            }
            return NavBarTitleConfiguration(title: title)
        }()
//        NavBarTitleConfiguration(title: "PunchPad", font: .system(size: 32))
        
        var navBarBackground: some View {
            RoundedRectangle(cornerRadius: 24)
                .foregroundColor(.white)
                .ignoresSafeArea(edges: .top)
                .background(Color.theme.background)
                .shadow(color: .black.opacity(0.2), radius: 12, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 4)
        }
        var leadingElements: some View {
            Logo.logo()
                .resizable()
                .frame(width: 26, height: 26)
        }
        var trailingElements: some View {
            Image(systemName:"gearshape.fill")
                .foregroundColor(.theme.primary)
        }
        
        var background: some View {
            Color.theme.background
                .ignoresSafeArea()
        }
        var body: some View {
            VStack(spacing: 0){
                CustomNavigationBarView(config: navBarTitleConfiguration,
                                        shouldShowBackButton: false,
                                        background: .init(view: AnyView(navBarBackground)),
                                        leadingElements: .init(view: AnyView(leadingElements)),
                                        trailingElements: .init(view: AnyView(trailingElements)),
                                        shouldElevate: false) { print("back tapped") }
                background
            }
            
        }
    }
    return Preview()
}

#Preview("History configuration") {
    struct Preview: View {
        let navBarTitleConfiguration = NavBarTitleConfiguration(title: "History", font: .system(size: 32,weight: .semibold))
        var navBarBackground: some View {
            RoundedRectangle(cornerRadius: 24)
                .foregroundColor(.white)
                .ignoresSafeArea(edges: .top)
                .background(Color.theme.background)
                .shadow(color: .black.opacity(0.2), radius: 12, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 4)
        }
        var leadingElements: some View {
            Image(systemName: "plus")
                .font(.title)
                .foregroundColor(.theme.primary)
        }
        var trailingElements: some View {
            Image(systemName:"gearshape.fill")
                .foregroundColor(.theme.primary)
        }
        
        var background: some View {
            Color.theme.background
                .ignoresSafeArea()
        }
        var body: some View {
            VStack(spacing: 0){
                CustomNavigationBarView(config: navBarTitleConfiguration,
                                        shouldShowBackButton: false,
                                        background: .init(view: AnyView(navBarBackground)),
                                        leadingElements: .init(view: AnyView(leadingElements)),
                                        trailingElements: .init(view: AnyView(trailingElements)),
                                        shouldElevate: true) { print("back tapped") }
                background
            }
            
        }
    }
    return Preview()
}

#Preview("Statistics configuration") {
    struct Preview: View {
        let navBarTitleConfiguration = NavBarTitleConfiguration(title: "Statistics", font: .system(size: 32))
        var navBarBackground: some View {
            RoundedRectangle(cornerRadius: 24)
                .foregroundColor(.white)
                .ignoresSafeArea(edges: .top)
                .background(Color.theme.background)
                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
        }
        var trailingElements: some View {
            Image(systemName:"gearshape.fill")
                .foregroundColor(.theme.primary)
        }
        var background: some View {
            Color.theme.background
                .ignoresSafeArea()
        }
        var body: some View {
            VStack(spacing: 0){
                CustomNavigationBarView(config: navBarTitleConfiguration,
                                        shouldShowBackButton: false,
                                        background: .init(view: AnyView(navBarBackground)),
                                        leadingElements: .init(),
                                        trailingElements: .init(view: AnyView(trailingElements)),
                                        shouldElevate: false) { print("back tapped") }
                background
            }
            
        }
    }
    return Preview()
}

#Preview("Settings configuration") {
    struct Preview: View {
        let navBarTitleConfiguration = NavBarTitleConfiguration(title: "Settings", font: .system(size: 32))
        var navBarBackground: some View {
            RoundedRectangle(cornerRadius: 24)
                .foregroundColor(.white)
                .ignoresSafeArea(edges: .top)
                .background(Color.theme.background)
                .shadow(color: .black.opacity(0.2), radius: 12, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 4)
        }
        var background: some View {
            Color.theme.background
                .ignoresSafeArea()
        }
        var body: some View {
            VStack(spacing: 0){
                CustomNavigationBarView(config: navBarTitleConfiguration,
                                        shouldShowBackButton: true,
                                        background: .init(view: AnyView(navBarBackground)),
                                        leadingElements: .init(),
                                        trailingElements: .init(),
                                        shouldElevate: true) { print("back tapped") }
                background
            }
            
        }
    }
    return Preview()
}

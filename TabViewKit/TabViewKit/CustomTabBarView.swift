//
//  CustomTabBarView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 28/12/2023.
//

import SwiftUI

struct CustomTabBarView: View {
    @Binding var selection: TabBarItem
    @State private var localSelection: TabBarItem
    @Namespace private var namespance
    let tabs: [TabBarItem]
    
    init(selection: Binding<TabBarItem>, tabs: [TabBarItem]) {
        self._selection = selection
        self._localSelection = State(initialValue: selection.wrappedValue)
        self.tabs = tabs
    }
    
    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                tabView(tab)
                    .onTapGesture {
                        switchTabs(tab: tab)
                    }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(
            Rectangle()
                .padding(.horizontal)
                .offset(CGSize(width: 0, height: 12))
                .foregroundColor(.red)//Color.theme.secondaryLabel)
                .frame(width: .infinity, height: 1)
        )
        .background(
            Color.white
                .frame(height: 120)
                .cornerRadius(24)
                .ignoresSafeArea(edges: .bottom)
        )
        .compositingGroup()
        .shadow(color: .black, radius: 6)//.theme.black.opacity(0.3), radius: 6, y: 4)
        .onChange(of: selection, perform: { value in
            withAnimation(.easeInOut) {
                localSelection = selection
            }
        })
    }
    
    private func tabView(_ tab: TabBarItem) -> some View {
        HStack {
            Image(systemName: tab.iconName)
                .font(.subheadline)
            Text(tab.title)
                .font(.system(size: 20))
//                .accessibilityIdentifier(tab.identifier)
        }
        .foregroundColor(.orange)
//        (localSelection == tab ? Color.theme.primary : Color.theme.secondaryLabel)
        .frame(maxWidth: .infinity)
        .background(
            ZStack{
                if localSelection == tab {
                    Rectangle()
                        .offset(CGSize(width: 0, height: 18))
                        .foregroundColor(.red)//Color.theme.primary)
                        .frame(width: .infinity, height: 3)
                        .matchedGeometryEffect(id: "tab_marker", in: namespance)
                }
            }
        )
        
    }
    
    private func switchTabs(tab: TabBarItem) {
        selection = tab
    }
}

#Preview("CustomTabBar") {
    struct Preview: View {
        @State private var tabSection: TabBarItem = .home
        var body: some View {
            ZStack {
//                BackgroundFactory.buildSolidColor()
                Color.teal.opacity(0.4).ignoresSafeArea()
                VStack{
                    Spacer()
                    CustomTabBarView(selection: $tabSection,
                                     tabs: [.home, .history, .statistics]
                    )
                }
            }
        }
    }
    return Preview()
}

//
//  CustomTabBarView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 28/12/2023.
//

import SwiftUI

public struct CustomTabBarView: View {
    @Binding var selection: TabBarItem
    @State private var localSelection: TabBarItem
    @Namespace private var namespance
    let tabs: [TabBarItem]
    let configuration: TabBarColorConfiguration
    
    public init(selection: Binding<TabBarItem>, tabs: [TabBarItem], colorConfiguration: TabBarColorConfiguration) {
        self._selection = selection
        self._localSelection = State(initialValue: selection.wrappedValue)
        self.tabs = tabs
        self.configuration = colorConfiguration
    }
    
    public var body: some View {
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
                .foregroundColor(configuration.inactiveColor)
                .frame(maxWidth: .infinity)
                .frame(height: 2)
        )
        .background(
            configuration.backgroundColor
                .frame(height: 120)
                .cornerRadius(24)
                .ignoresSafeArea(edges: .bottom)
        )
        .compositingGroup()
        .shadow(color: configuration.shadowColor, radius: 6, y: 4)
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
                .accessibilityIdentifier(tab.identifier)
        }
        .foregroundColor(localSelection == tab ? configuration.activeColor : configuration.inactiveColor)
        .frame(maxWidth: .infinity)
        .background(
            ZStack{
                if localSelection == tab {
                    Rectangle()
                        .offset(CGSize(width: 0, height: 18))
                        .foregroundColor(configuration.activeColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 3)
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
                Color.green.ignoresSafeArea()
                VStack{
                    Spacer()
                    CustomTabBarView(selection: $tabSection,
                                     tabs: [.home, .history, .statistics],
                                     colorConfiguration: TabBarColorConfiguration()
                    )
                }
            }
        }
    }
    return Preview()
}

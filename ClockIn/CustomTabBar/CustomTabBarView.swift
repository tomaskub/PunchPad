//
//  CustomTabBarView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 28/12/2023.
//

import SwiftUI

struct CustomTabBarView: View {
    @Binding var selection: TabBarItem
    let tabs: [TabBarItem]
    
    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                tabView(tab)
                    .onTapGesture {
                        switchTabs(tab: tab)
                    }
            }
            .frame(height: 36)
            .padding(6)
        }
        .background(
            Rectangle()
                .offset(CGSize(width: 0, height: 18))
                .foregroundColor(Color.theme.secondaryLabel)
                .frame(width: .infinity, height: 1)
        )
        .background(
            Color.white
                .frame(height: 120)
                .cornerRadius(24)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    private func tabView(_ tab: TabBarItem) -> some View {
        HStack {
            Image(systemName: tab.iconName)
                .font(.subheadline)
            Text(tab.title)
                .font(.system(size: 20))
                .accessibilityIdentifier(tab.identifier)
        }
        .foregroundColor(selection == tab ? Color.theme.primary : Color.theme.secondaryLabel)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .offset(CGSize(width: 0, height: 18))
                .foregroundColor(selection == tab ? .theme.primary : Color.clear)
                .frame(width: .infinity, height: 3)
        )
        
    }
    
    private func switchTabs(tab: TabBarItem) {
        selection = tab
    }
}

#Preview("CustomTabBar") {
    ZStack {
        BackgroundFactory.buildSolidColor()
        VStack{
            Spacer()
            CustomTabBarView(selection: .constant( .home),
                             tabs: [.home, .history, .statistics]
            )
        }
    }
}

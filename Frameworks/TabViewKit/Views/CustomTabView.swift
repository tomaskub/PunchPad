//
//  CustomTabBarContainerView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 28/12/2023.
//

import SwiftUI

public struct CustomTabView<Content: View>: View  {
    let content: Content
    let tabBarColorConfig: TabBarColorConfiguration
    @Binding var selection: TabBarItem
    @State private var tabs: [TabBarItem] = []
    
    public init(selection: Binding<TabBarItem>, 
                tabBarColorConfiguration: TabBarColorConfiguration,
                @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.tabBarColorConfig = tabBarColorConfiguration
        self.content = content()
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            content
            CustomTabBarView(selection: $selection,
                             tabs: tabs,
            colorConfiguration: tabBarColorConfig)
        }
        .onPreferenceChange(TabBarItemsPrefKey.self) { value in
            self.tabs = value
        }
    }
}

#Preview {
    CustomTabView(selection: .constant(.home), tabBarColorConfiguration: TabBarColorConfiguration()) {
        Color.red
    }
}

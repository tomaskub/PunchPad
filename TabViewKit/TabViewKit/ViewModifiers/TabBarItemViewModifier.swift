//
//  TabBarItemViewModifier.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 28/12/2023.
//

import SwiftUI

struct TabBarItemViewModifier: ViewModifier {
    @Binding var selection: TabBarItem
    let tab: TabBarItem
    
    func body(content: Content) -> some View {
        content
            .opacity(selection == tab ? 1.0 : 0.0)
            .preference(key: TabBarItemsPrefKey.self, value: [tab])
    }
}

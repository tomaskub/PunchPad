//
//  EmptyPlaceholderModifier.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 11/12/2023.
//

import SwiftUI

struct EmptyPlaceholderModifier<T: Collection>: ViewModifier {
    private let items: T
    private let placeholder: AnyView
    
    init(items: T, placeholder: AnyView) {
        self.items = items
        self.placeholder = placeholder
    }
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if !items.isEmpty {
            content
        } else {
            placeholder
        }
    }
}

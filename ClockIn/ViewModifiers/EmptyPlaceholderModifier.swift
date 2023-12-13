//
//  EmptyPlaceholderModifier.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 11/12/2023.
//

import SwiftUI

struct EmptyPlaceholderModifier<T: Collection>: ViewModifier {
    let items: T
    let placeholder: AnyView
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if !items.isEmpty {
            content
        } else {
            placeholder
        }
    }
}

//
//  View+Extension.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 15/11/2023.
//

import SwiftUI

extension View {
    /// Applies given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///     - condition: The condition to evaluate.
    ///     - transform: The transform to apply to the source `View`.
    /// - Returns: Modified `View` or original `View`
    @ViewBuilder
    func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
    /// Applies given transform if the given value is not `nil`.
    /// - Parameters:
    ///     - value: The parameter to check for `nil` value
    ///     - transform: The transform to apply to the source `View` with unwrapped `value`.
    /// - Returns: Modified `View` or original `View`
    @ViewBuilder
    func ifLet<V, Transform: View>(_ value: V?, transform: (Self, V) -> Transform) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
    
    func emptyPlaceholder<Items: Collection, PlaceholderView: View>(_ items: Items, _ placeholder: @escaping () -> PlaceholderView) -> some View {
        self.modifier(
            EmptyPlaceholderModifier(items: items,
                                     placeholder: AnyView(placeholder())
                                    )
        )
    }
}


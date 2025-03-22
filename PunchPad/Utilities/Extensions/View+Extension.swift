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
    
    /// Applies empty placeholder modifier trigering display of placeholder view if items collection is empty
    func emptyPlaceholder<Items: Collection, PlaceholderView: View>(
        _ items: Items,
        _ placeholder: @escaping () -> PlaceholderView
    ) -> some View {
        self.modifier(
            EmptyPlaceholderModifier(items: items,
                                     placeholder: AnyView(placeholder())
                                    )
        )
    }
    
    /// Animate in sync within a task.
    /// - Parameters:
    ///   - duration: length before next animation within a task will start
    ///   - animation: animation to be used when animating the view
    ///   - execute: change to execute
    /// Use case:
    ///   .onTapGesture {
    ///    Task {
    ///        let duration: TimeInterval = 0.2
    ///        await animate(duration: duration, animation: .spring(duration: duration)) {
    ///            isShowingOverrideControls.toggle()
    ///        }
    ///
    ///        await animate(duration: duration, animation: .spring(duration: duration)) {
    ///            proxy.scrollTo("editControls", anchor: .top)
    ///        }
    ///     }
    /// }
    func animate(duration: TimeInterval, animation: Animation, _ execute: @escaping () -> Void) async {
        await withCheckedContinuation { continuation in
            withAnimation(animation) {
                execute()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                continuation.resume()
            }
        }
    }
}

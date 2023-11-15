//
//  View+Extension.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 15/11/2023.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func ifLet<V, Transform: View>(_ value: V?, transform: (Self, V) -> Transform) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}

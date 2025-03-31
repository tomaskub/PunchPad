//
//  Binding+Extension.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 31/01/2025.
//

import SwiftUI

extension Binding where Value: AdditiveArithmetic {
    var nilIfZero: Binding<Value?> {
        Binding<Value?> {
            self.wrappedValue == .zero ? nil : self.wrappedValue
        } set: { newValue in
            self.wrappedValue = newValue ?? .zero
        }
    }
}

//
//  ButtonFactory.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 04/11/2023.
//

import SwiftUI

struct ButtonFactory {
    @ViewBuilder
    static func build(labelText: String) -> some View {
        Text(labelText)
            .font(.headline)
            .foregroundColor(.blue)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(Color.primary.colorInvert())
            .cornerRadius(10)
    }
}

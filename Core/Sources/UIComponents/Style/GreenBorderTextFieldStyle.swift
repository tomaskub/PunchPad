//
//  GreenBorderTextFieldStyle.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 03/01/2024.
//

import SwiftUI

struct GreenBorderTextFieldStyle: TextFieldStyle {
    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.all, 8)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.theme.primary, lineWidth: 1)
            }
    }
}

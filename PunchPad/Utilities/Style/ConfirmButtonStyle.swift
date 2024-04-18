//
//  ConfirmButtonStyle.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 02/01/2024.
//

import ThemeKit
import SwiftUI

struct ConfirmButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.theme.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(
                Color.theme.primary
            )
            .cornerRadius(8)
    }
}

#Preview {
    Button { } label: {
        Text("ConfirmButtonStyle")
    }
    .buttonStyle(ConfirmButtonStyle())
    .padding()
}

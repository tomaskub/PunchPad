//
//  CancelButtonStyle.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 02/01/2024.
//

import SwiftUI
import ThemeKit

struct CancelButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.theme.buttonLabelGray)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    Button { } label: {
        Text("CancelButtonStyle")
    }
    .buttonStyle(CancelButtonStyle())
    .padding()
}

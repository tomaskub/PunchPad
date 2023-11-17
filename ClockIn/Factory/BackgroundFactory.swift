//
//  GradientFactory.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 31/08/2023.
//

import SwiftUI

struct BackgroundFactory {
    @ViewBuilder
    static func buildGradient(colorScheme: ColorScheme) -> some View {
        LinearGradient(
            colors: [ colorScheme == .light ? .white : .black, .blue.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    static func buildSolidColor(_ color: Color? = nil) -> some View {
        if let color {
            color.ignoresSafeArea()
        } else {
            Color.theme.background
                .ignoresSafeArea()
        }
    }
}

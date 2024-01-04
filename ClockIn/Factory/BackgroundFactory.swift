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
    
    @ViewBuilder
    static func buildNavBarBackground() -> some View {
        RoundedRectangle(cornerRadius: 24)
            .foregroundColor(.theme.white)
            .ignoresSafeArea(edges: .top)
            .background(Color.theme.background)
    }
    
    @ViewBuilder
    static func buildSolidWithStrip(solid color: Color = .theme.background, strip stripColor: Color = .theme.white) -> some View {
        ZStack {
            color
            VStack {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundColor(stripColor)
                    .frame(width: .infinity, height: 120)
                    .shadow(color: color.opacity(0.3), radius: 12, x: 0, y: 4)
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

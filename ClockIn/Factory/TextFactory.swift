//
//  TextFactory.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 05/11/2023.
//

import SwiftUI

struct TextFactory {
    @ViewBuilder
    static func buildTitle(_ text: String) -> some View {
        Text(text)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .overlay {
                Capsule()
                    .frame(height: 3)
                    .offset(y: 20)
                    .foregroundColor(.primary)
            }
    }
    @ViewBuilder
    static func buildMultilineTitle(_ text: String) -> some View {
        Text(text)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    static func buildDescription(_ text: String) -> some View {
        Text(text)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    static func buildSectionHeader(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.theme.primary)
            .font(.system(size: 24, weight: .medium))
    }
}

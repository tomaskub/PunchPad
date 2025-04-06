//
//  TextFactory.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 05/11/2023.
//

import SwiftUI
import ThemeKit

public struct TextFactory {
    @ViewBuilder
    public static func buildTitle(_ text: String) -> some View {
        Text(text)
            .font(.largeTitle)
            .fontWeight(.semibold)
    }
    @ViewBuilder
    public static func buildMultilineTitle(_ text: String) -> some View {
        Text(text)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    public static func buildDescription(_ text: String) -> some View {
        Text(text)
            .fontWeight(.medium)
            .foregroundColor(.theme.blackLabel)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    public static func buildSectionHeader(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.theme.primary)
            .font(.system(size: 24, weight: .medium))
    }
}

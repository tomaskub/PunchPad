//
//  NavBarTitleConfiguration.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI
import ThemeKit

public struct NavBarTitleConfiguration: Equatable {
    public var title: String
    public var textColor: Color
    public var font: Font
    public var alignment: Alignment
    
    
    public init(title: String, textColor: Color = .theme.black, font: Font = .title, alignment: Alignment = .leading) {
        self.title = title
        self.textColor = textColor
        self.alignment = alignment
        self.font = font
    }
}

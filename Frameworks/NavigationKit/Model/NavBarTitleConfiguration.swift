//
//  NavBarTitleConfiguration.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

public struct NavBarTitleConfiguration: Equatable {
    public var title: AttributedString
    public var alignment: Alignment
    
    public init(title: String, textColor: Color = .black, font: Font = .title, alignment: Alignment = .leading) {
        self.title = {
            var attributedString = AttributedString(title)
            attributedString.font = font
            attributedString.foregroundColor = textColor
            return attributedString
        }()
        self.alignment = alignment
    }
    
    public init(title: AttributedString, alignment: Alignment = .leading) {
        self.title = title
        self.alignment = alignment
    }
}

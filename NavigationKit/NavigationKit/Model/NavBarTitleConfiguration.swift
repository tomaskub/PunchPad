//
//  NavBarTitleConfiguration.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

public struct NavBarTitleConfiguration: Equatable {
    public var title: String
    public var textColor: Color
    public var alignment: Alignment
    
    public init(title: String, textColor: Color = .primary, alignment: Alignment = .leading) {
        self.title = title
        self.textColor = textColor
        self.alignment = alignment
    }
}

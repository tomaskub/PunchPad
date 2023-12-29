//
//  EquatableView.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

public struct EquatableView: Equatable {
    
    public static func == (lhs: EquatableView, rhs: EquatableView) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id = UUID().uuidString
    let view: AnyView
    
    public init(view: AnyView = AnyView(EmptyView())) {
        self.view = view
    }
}

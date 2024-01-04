//
//  EquatableView.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

public struct _EquatableView: Equatable {
    static let defaultView: _EquatableView = .init()
    public static func == (lhs: _EquatableView, rhs: _EquatableView) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id = UUID().uuidString
    let view: AnyView
    
    public init(view: AnyView = AnyView(EmptyView())) {
        self.view = view
    }
}


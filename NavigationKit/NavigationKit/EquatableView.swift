//
//  EquatableView.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

struct EquatableView: Equatable {
    
    static func == (lhs: EquatableView, rhs: EquatableView) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id = UUID().uuidString
    let view: AnyView
    
    init(view: AnyView = AnyView(EmptyView())) {
        self.view = view
    }
}

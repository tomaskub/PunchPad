//
//  VerticalDivider.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 02/01/2024.
//

import SwiftUI

struct VerticalDivider: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

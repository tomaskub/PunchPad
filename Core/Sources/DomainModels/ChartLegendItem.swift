//
//  ChartLegendItem.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 12/11/2023.
//

import SwiftUI

public struct ChartLegendItem: Identifiable {
    public let id: UUID
    public let itemName: String
    public let itemShape: AnyShape
    public let itemShapeColor: Color
    
    public init(itemName: String, itemShape: any Shape, itemShapeColor: Color) {
        self.id = UUID()
        self.itemName = itemName
        self.itemShape = AnyShape(itemShape)
        self.itemShapeColor = itemShapeColor
    }
}

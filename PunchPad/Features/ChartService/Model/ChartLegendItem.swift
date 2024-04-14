//
//  ChartLegendItem.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 12/11/2023.
//

import SwiftUI

struct ChartLegendItem: Identifiable {
    let id: UUID
    let itemName: String
    let itemShape: AnyShape
    let itemShapeColor: Color
    
    init(itemName: String, itemShape: any Shape, itemShapeColor: Color) {
        self.id = UUID()
        self.itemName = itemName
        self.itemShape = AnyShape(itemShape)
        self.itemShapeColor = itemShapeColor
    }
}

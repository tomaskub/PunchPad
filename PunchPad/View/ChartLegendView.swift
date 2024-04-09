//
//  ChartLegendView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 10/11/2023.
//

import SwiftUI

struct ChartLegendView: View {
    private let chartLegendItems: [ChartLegendItem]
    
    init(chartLegendItems: [ChartLegendItem]) {
        self.chartLegendItems = chartLegendItems
    }
    
    var body: some View {
        HStack {
            Text("Legend:")
            ForEach(chartLegendItems) { item in
                ChartLegendItemView(chartLegendItem: item)
            }
        }
    }
}

struct ChartLegendView_Previews: PreviewProvider {
    static var previews: some View {
        ChartLegendView(chartLegendItems: [
            ChartLegendItem(itemName: "Rectangle", itemShape: Rectangle(), itemShapeColor: .blue),
            ChartLegendItem(itemName: "Circle", itemShape: Circle(), itemShapeColor: .green)
        ])
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Chart Legend View")
    }
}




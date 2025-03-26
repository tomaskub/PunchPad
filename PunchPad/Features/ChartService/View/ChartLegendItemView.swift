//
//  ChartLegendItemView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 12/11/2023.
//

import SwiftUI

struct ChartLegendItemView: View {
    private let chartLegendItem: ChartLegendItem
    
    init(chartLegendItem: ChartLegendItem) {
        self.chartLegendItem = chartLegendItem
    }
    
    var body: some View {
        HStack {
            chartLegendItem.itemShape
                .fill(chartLegendItem.itemShapeColor)
                .frame(width: 14, height: 14)
            Text(chartLegendItem.itemName)
        }
    }
}

struct ChartLegendItemView_Previews: PreviewProvider {
    static var previews: some View {
        ChartLegendItemView(chartLegendItem: ChartLegendItem(itemName: "Rectangles",
                                                             itemShape: Rectangle(),
                                                             itemShapeColor: .red))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

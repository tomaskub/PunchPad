//
//  ChartFactory.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 12/11/2023.
//

import SwiftUI
import Charts

struct ChartFactory {
    // TODO: ADD FLEXIBILITY WITH KEY PATHS
    @ViewBuilder
    static func buildBarChart(entries: [Entry], includeRuleMark: Bool) -> some View {
            Chart(entries) {
                // ruler
                if includeRuleMark {
                    RuleMark(y: .value("WorkGoal", 8))
                        .lineStyle(.init(dash: [10]))
                        .foregroundStyle(.red)
                }
                
                BarMark(
                    x: .value("Date", $0.startDate, unit: .day),
                    y: .value("Hours worked", $0.workTimeInSeconds / 3600))
                .foregroundStyle(.blue)
                .cornerRadius(10)
                
                BarMark(x: .value("Date", $0.startDate,unit: .day),
                        y: .value("Hours worked", $0.overTimeInSeconds / 3600))
                .foregroundStyle(.green)
                .cornerRadius(10)
            }
            
            //Additional chart properties x-axis and y-scale
            .chartYScale(domain: 0...15)
            ChartLegendView(chartLegendItems: [
                ChartLegendItem(itemName: "Hours worked", itemShape: Rectangle(), itemShapeColor: .blue),
                ChartLegendItem(itemName: "Overtime", itemShape: Rectangle(), itemShapeColor: .green)])
            .font(.caption)
    }
    
    @ViewBuilder
    static func buildPointChartForPunchTime(entries: [Entry], property: KeyPath<Entry, Date>, color: Color, displayName: String) -> some View {
        Chart(entries) {
            PointMark(
                x: .value("Date", $0.startDate),
                y: .value("Date", Calendar.current.dateComponents([.hour, .minute], from: $0[keyPath: property]).hour!)
            )
            .foregroundStyle($0.workTimeInSeconds == 0 ? .clear : color)
        }
        .chartYScale(domain: 0...24)
        ChartLegendView(chartLegendItems: [
        ChartLegendItem(itemName: displayName, itemShape: Circle(), itemShapeColor: color)])
        .font(.caption)
    }
}

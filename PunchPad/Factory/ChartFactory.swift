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
    static func buildBarChart(entries: [Entry], firstColor: Color, secondColor: Color, axisColor: Color, includeRuleMark: Bool = false) -> some View {
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
                .foregroundStyle(firstColor)
                
                BarMark(x: .value("Date", $0.startDate,unit: .day),
                        y: .value("Hours worked", $0.overTimeInSeconds / 3600))
                .foregroundStyle(secondColor)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                        .foregroundStyle(axisColor)
                    
                    AxisValueLabel() {
                        if let date = value.as(Date.self) {
                            Text(FormatterFactory.makeDayAndMonthDateFormatter().string(from: date))
                                .foregroundStyle(axisColor)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                        .foregroundStyle(axisColor)
                    
                    AxisValueLabel() {
                        if let intVal = value.as(Int.self) {
                            Text("\(intVal)")
                                .foregroundStyle(axisColor)
                        }
                    }
                }
            }
            .chartYScale(domain: 0...15)
    }
    
    @ViewBuilder
    static func buildBarChartForYear(data: [MonthEntrySummary], firstColor: Color, secondColor: Color) -> some View {
        Chart(data) { summary in
            BarMark(x: .value("Date", summary.startDate, unit: .month),
                    y: .value("Hours worked", summary.workTimeInSeconds / 3600)
            )
            .foregroundStyle(firstColor)
            
            BarMark(x: .value("Date", summary.startDate, unit: .month),
                    y: .value("Hours overtime", summary.overtimeInSecond / 3600)
            )
            .foregroundStyle(secondColor)
        }
    }
    
    @ViewBuilder
    static func buildChartLegend() -> some View {
        ChartLegendView(chartLegendItems: [
            ChartLegendItem(itemName: "Hours worked", itemShape: Rectangle(), itemShapeColor: .blue),
            ChartLegendItem(itemName: "Overtime", itemShape: Circle(), itemShapeColor: .green)])
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

//
//  ChartFactory.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 12/11/2023.
//

import SwiftUI
import Charts
import ThemeKit

struct ChartFactory {
    /// Build chart using buildBarChart function with default colors from theme kit, x axis unis set to day and x axis value labels formatter to 2 digit days and 3 letter description of month (such as `21 Jun`)
    /// - Parameter data: array of chartableEntry data
    /// - Returns: Chart view
    @ViewBuilder static func buildBarChartForDays<T: ChartableEntry>(data: [T]) -> some View {
        buildBarChartWithDefaultColors(data: data,
                                       xUnit: .day,
                                       xFormatter: FormatterFactory.makeDayAndMonthDateFormatter(),
                                       yScale: 0...15)
    }
    
    /// Build chart using buildBarChart function with default colors from theme kit, x axis unis set to week of year and x axis value labels formatter to 2 digit days and 3 letter description of month (such as `21 Jun`)
    /// - Parameter data: array of chartableEntry data
    /// - Returns: Chart view
    @ViewBuilder static func buildBarChartForWeeks<T: ChartableEntry>(data: [T]) -> some View {
        buildBarChartWithDefaultColors(data: data,
                                       xUnit: .weekOfYear,
                                       xFormatter: FormatterFactory.makeDayAndMonthDateFormatter(),
                                       yScale: nil)
    }
    
    
    /// Build chart using buildBarChart function with default colors from theme kit, x axis unis set to month and x axis value labels formatter to 3 letter description of month (such as `Jun`)
    /// - Parameter data: array of chartableEntry data
    /// - Returns: Chart view
    @ViewBuilder static func buildBarChartForMonths<T: ChartableEntry>(data: [T]) -> some View {
        buildBarChartWithDefaultColors(data: data,
                                       xUnit: .month,
                                       xFormatter: FormatterFactory.makeMonthDateFormatter(),
                                       yScale: nil)
    }
    
    /// Build chart using buildBarChart function with default colors defined in ThemeKit
    /// - Parameters:
    ///   - data: array of chartableEntry data to be displayed
    ///   - xUnit: Calendar component unit to be used for x axis
    ///   - xFormatter: formatter used for x axis values of data
    ///   - yScale: optional scale to be used on y axis
    /// - Returns: Chart view
    @ViewBuilder static func buildBarChartWithDefaultColors<T: ChartableEntry>(data: [T], xUnit: Calendar.Component, xFormatter: DateFormatter, yScale: ClosedRange<Int>? = nil) -> some View {
        buildBarChart(data: data, firstColor: .theme.primary, secondColor: .theme.redChart, axisColor: .theme.buttonColor, xUnit: xUnit, xFormatter: xFormatter, yScale: yScale)
    }
    
    /// Build BarChart based on chartable entry array
    /// - Parameters:
    ///   - data: array of data to be displayed
    ///   - firstColor: color of bar representing worktime
    ///   - secondColor: color of bar representing overtime
    ///   - axisColor: color of axis features - marks, gridlines, labels
    ///   - xUnit: Calendar component unit to be used for x axis
    ///   - xFormatter: formatter used for x axis values of data
    ///   - yScale: optional scale to be used on y axis
    /// - Returns: Chart View
    @ViewBuilder static func buildBarChart<T: ChartableEntry>(data: [T], firstColor: Color, secondColor: Color, axisColor: Color, xUnit: Calendar.Component, xFormatter: DateFormatter, yScale: ClosedRange<Int>? = nil) -> some View {
            Chart(data) {
                BarMark(
                    x: .value("Date", $0.startDate, unit: xUnit),
                    y: .value("Hours worked", $0.workTimeInSeconds / 3600))
                .foregroundStyle(firstColor)
                
                BarMark(x: .value("Date", $0.startDate,unit: xUnit),
                        y: .value("Hours worked", $0.overTimeInSeconds / 3600))
                .foregroundStyle(secondColor)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                        .foregroundStyle(axisColor)
                    
                    AxisValueLabel() {
                        if let date = value.as(Date.self) {
                            Text(xFormatter.string(from: date))
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
            .ifLet(yScale, transform: { chart, domain in
                chart.chartYScale(domain: domain)
            })
    }
    
    /// Build chart legend view for hours worked and overtime
    /// - Returns: ChartLegendView
    @ViewBuilder static func buildChartLegend() -> some View {
        ChartLegendView(chartLegendItems: [
            ChartLegendItem(itemName: "Hours worked", itemShape: Rectangle(), itemShapeColor: .blue),
            ChartLegendItem(itemName: "Overtime", itemShape: Circle(), itemShapeColor: .green)])
        .font(.caption)
    }
    
    /// Build Chart view with point mark data for entry array hour porperty
    /// - Parameters:
    ///   - entries: entry array to be displayed on chart
    ///   - property: keyPath to property from which to display hour from
    ///   - color: color of point marker
    ///   - displayName: display name to show on legend
    /// - Returns: Chart with point markers
    @ViewBuilder static func buildPointChartForPunchTime(entries: [Entry], property: KeyPath<Entry, Date>, color: Color, displayName: String) -> some View {
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

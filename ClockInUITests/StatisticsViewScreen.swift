//
//  StatisticsViewScreen.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 02/09/2023.
//

import XCTest

class StatisticsViewScreen {
    private typealias Identifier = ScreenIdentifier.StatisticsView
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var workTimeChart: XCUIElement {
        app.otherElements[Identifier.Chart.workTimeChart.rawValue]
    }
    
    var startTimeChart: XCUIElement {
        app.otherElements[Identifier.Chart.startTimeChart.rawValue]
    }
    
    var finishTimeChart: XCUIElement {
        app.otherElements[Identifier.Chart.finishTimeChart.rawValue]
    }
    
    var chartTypeSegmentedControl: XCUIElement {
        app.segmentedControls[Identifier.SegmentedControl.chartType.rawValue]
    }
    
    var workTimeChartButton: XCUIElement {
        app.buttons[Identifier.ChartTypeButton.workTime.rawValue]
    }
    
    var startTimeChartButton: XCUIElement {
        app.buttons[Identifier.ChartTypeButton.startTime.rawValue]
    }
    
    var finishTimeChartButton: XCUIElement {
        app.buttons[Identifier.ChartTypeButton.finishTime.rawValue]
    }
    
    var workTimeChartLegend: XCUIElement {
        app.otherElements[Identifier.ChartLegend.workTimeChartLegend.rawValue]
    }
    
    var startTimeChartLegend: XCUIElement {
        app.otherElements[Identifier.ChartLegend.startTimeChartLegend.rawValue]
    }
    
    var finishTimeChartLegend: XCUIElement {
        app.otherElements[Identifier.ChartLegend.finishTimeChartLegend.rawValue]
    }
    
    var grossPayLabel: XCUIElement {
        app.staticTexts[Identifier.SalaryCalculationLabel.grossPay.rawValue]
    }
    
    var netPayLabel: XCUIElement {
        app.staticTexts[Identifier.SalaryCalculationLabel.netPay.rawValue]
    }
    
    var chartSectionHeader: XCUIElement {
        app.staticTexts[Identifier.SectionHeaders.chart.rawValue]
    }
    
    var salaryCalculationSectionHeader: XCUIElement {
        app.staticTexts[Identifier.SectionHeaders.salaryCalculation.rawValue]
    }
    
    var detailedHistoryNavigationButton: XCUIElement {
        app.buttons[Identifier.NavigationBarButtons.detailedHistory.rawValue]
    }
}

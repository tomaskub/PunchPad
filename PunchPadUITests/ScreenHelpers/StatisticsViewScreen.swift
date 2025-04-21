//
//  StatisticsViewScreen.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 02/09/2023.
//

import DomainModels
import XCTest

class StatisticsViewScreen {
    private typealias Identifier = ScreenIdentifier.StatisticsView
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var chart: XCUIElement {
        app.cells[Identifier.workTimeChart.rawValue]
    }
    
    var salaryCalculationSectionHeader: XCUIElement {
        app.staticTexts[Identifier.SectionHeaders.salaryCalculation.rawValue]
    }
    
    var allRangeSegmentedButton: XCUIElement {
        app.segmentedControls.buttons[Identifier.SegmentedControl.allRange.rawValue]
    }
    
    var weekRangeSegmentedButton: XCUIElement {
        app.segmentedControls.buttons[Identifier.SegmentedControl.weekRange.rawValue]
    }
    
    var monthRangeSegmentedButton: XCUIElement {
        app.segmentedControls.buttons[Identifier.SegmentedControl.monthRange.rawValue]
    }
    
    var yearRangeSegmentedButton: XCUIElement {
        app.segmentedControls.buttons[Identifier.SegmentedControl.yearRange.rawValue]
    }
    
    var periodLabel: XCUIElement {
        app.staticTexts[Identifier.SalaryCalculationLabel.period.rawValue]
    }
    
    var grossPayPerHourLabel: XCUIElement {
        app.staticTexts[Identifier.SalaryCalculationLabel.grossPayPerHour.rawValue]
    }
    
    var grossPayLabel: XCUIElement {
        app.staticTexts[Identifier.SalaryCalculationLabel.grossPay.rawValue]
    }
    
    var grossPayPredictedLabel: XCUIElement {
        app.staticTexts[Identifier.SalaryCalculationLabel.grossPayPredicted.rawValue]
    }
    
    var workDaysNumberLabel: XCUIElement {
        app.staticTexts[Identifier.SalaryCalculationLabel.workingDaysNumber.rawValue]
    }
}

//
//  OnboardingViewScreen.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 02/09/2023.
//

import XCTest

class OnboardingViewScreen {
    private typealias Identifier = ScreenIdentifier.OnboardingView
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var workingHoursPicker: XCUIElement {
        app.pickers[Identifier.Pickers.workingHours.rawValue]
    }
    
    var workingMinutesPicker: XCUIElement {
        app.pickers[Identifier.Pickers.workingMinutes.rawValue]
    }
    
    var overtimeHoursPicker: XCUIElement {
        app.pickers[Identifier.Pickers.overtimeHours.rawValue]
    }
    
    var overtimeMinutesPicker: XCUIElement {
        app.pickers[Identifier.Pickers.overtimeMinutes.rawValue]
    }
    
    var grossPaycheckTextField: XCUIElement {
        app.textFields[Identifier.TextFields.grossPaycheck.rawValue]
    }
    
    var overtimeToggleButton: XCUIElement {
        app.switches[Identifier.Toggles.overtime.rawValue]
    }
    
    var notificationToggleButton: XCUIElement {
        app.switches[Identifier.Toggles.notifications.rawValue]
    }
    
    var calculateNetSalaryToggleButton: XCUIElement {
        app.switches[Identifier.Toggles.calculateNetSalary.rawValue]
    }
    
    var advanceStageButton: XCUIElement {
        app.buttons[Identifier.Buttons.advanceStage.rawValue]
    }
    
    var regressStageButton: XCUIElement {
        app.staticTexts[Identifier.Buttons.regressStage.rawValue]
    }
}

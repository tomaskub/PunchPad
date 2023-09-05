//
//  SettingsViewScreen.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 05/09/2023.
//

import XCTest

class SettingsViewScreen {
    private typealias Identifier = ScreenIdentifier.SettingsView
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var setTimeLengthExapndButton: XCUIElement {
        app.cells[Identifier.ExpandableCells.setTimerLength.rawValue]
    }
    
    var setOvertimeLengthExpanButton: XCUIElement {
        app.cells[Identifier.ExpandableCells.setOvertimeLength.rawValue]
    }
    
    var sendNotificationsToggle: XCUIElement {
        app.switches[Identifier.ToggableCells.sendNotificationsOnFinish.rawValue]
    }
    
    var keepLogginOvertimeToggle: XCUIElement {
        app.switches[Identifier.ToggableCells.keepLoggingOvertime.rawValue]
    }
    
    var calculateNetPayToggle: XCUIElement {
        app.switches[Identifier.ToggableCells.calculateNetPay.rawValue]
    }
    
    var appearanceSystemButton: XCUIElement {
        app.buttons[Identifier.SegmentedControlButtons.system.rawValue]
    }
    
    var appearanceDarkButton: XCUIElement {
        app.buttons[Identifier.SegmentedControlButtons.dark.rawValue]
    }
    
    var appearanceLightButton: XCUIElement {
        app.buttons[Identifier.SegmentedControlButtons.light.rawValue]
    }
    
    var clearAllSavedDataButton: XCUIElement {
        app.cells[Identifier.ButtonCells.clearAllSavedData.rawValue]
    }
    
    var resetPreferencesButton: XCUIElement {
        app.cells[Identifier.ButtonCells.resetPreferences.rawValue]
    }
    
    var workTimeHoursPicker: XCUIElement {
        app.pickers[Identifier.Pickers.timeHoursPicker.rawValue]
    }
    
    var workMinutesHoursPicker: XCUIElement {
        app.pickers[Identifier.Pickers.timeMinutesPicker.rawValue]
    }
    
    var overtimeHoursPicker: XCUIElement {
        app.pickers[Identifier.Pickers.overtimeHoursPicker.rawValue]
    }
    
    var overtimeMinutesPicker: XCUIElement {
        app.pickers[Identifier.Pickers.overtimeMinutesPicker.rawValue]
    }
    
    var grossPaycheckTextField: XCUIElement {
        app.textFields[Identifier.TextFields.grossPay.rawValue]
    }
}

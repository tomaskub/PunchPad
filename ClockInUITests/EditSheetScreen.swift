//
//  EditSheetScreen.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 09/09/2023.
//

import XCTest

class EditSheetScreen {
    
    private typealias Identifier = ScreenIdentifier.EditSheetView
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var startDatePicker: XCUIElement {
        app.datePickers[Identifier.DatePicker.startDate.rawValue]
    }
    
    var finishDatePicker: XCUIElement {
        app.datePickers[Identifier.DatePicker.finishDate.rawValue]
    }
    
    var timeWorkedValueLabel: XCUIElement {
        app.staticTexts[Identifier.Label.timeWorkedValue.rawValue]
    }
    
    var overtimeValueLabel: XCUIElement {
        app.staticTexts[Identifier.Label.overtimeValue.rawValue]
    }
    
    var saveButton: XCUIElement {
        app.buttons[Identifier.Button.save.rawValue]
    }
    
    var cancelButton: XCUIElement {
        app.buttons[Identifier.Button.cancel.rawValue]
    }
    
    var popoverDismissButton: XCUIElement {
        app.buttons["PopoverDismissRegion"]
    }
}

//
//  HistoryViewScreen.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 08/09/2023.
//

import XCTest

final class HistoryViewScreen {
    
    private typealias Identifier = ScreenIdentifier.HistoryView
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var addEntryButton: XCUIElement {
        app.buttons[Identifier.addEntryButton.rawValue]
    }
    
    var entryRows: XCUIElement {
        app.cells[Identifier.entryRow.rawValue]
    }
    
    var deleteEntryButton: XCUIElement {
        app.buttons[Identifier.deleteEntryButton.rawValue]
    }
    
    var editEntryButton: XCUIElement {
        app.buttons[Identifier.editEntryButton.rawValue]
    }
}

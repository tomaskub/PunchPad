//
//  HistoryViewScreen.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 08/09/2023.
//

import DomainModels
import XCTest

final class HistoryViewScreen {
    
    private typealias Identifier = ScreenIdentifier.HistoryView
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var addEntryButton: XCUIElement {
        app.images[Identifier.addEntryButton.rawValue]
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
    
    var dialogOkButton: XCUIElement {
        app.buttons[Identifier.ConfirmDeleteDialogView.okButton.rawValue]
    }
    
    var dialogCancelButton: XCUIElement {
        app.buttons[Identifier.ConfirmDeleteDialogView.cancelButton.rawValue]
    }
    
    var dialogLabel: XCUIElement {
        app.staticTexts[Identifier.ConfirmDeleteDialogView.dialogLabel.rawValue]
    }
    
    var emptyStateLabel: XCUIElement {
        app.staticTexts[Identifier.emptyPlaceholder.rawValue]
    }
}

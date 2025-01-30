//
//  HistoryViewUITests.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 08/09/2023.
//

import XCTest

final class HistoryViewUITests: XCTestCase {
    
    private let standardTimeout: Double = 2.5
    private var app: XCUIApplication!
    
    private let existsPredicate = NSPredicate(format: "exists == true")
    private let notExistPredicate = NSPredicate(format: "exists == false")
    
    private var historyScreen: HistoryViewScreen {
        HistoryViewScreen(app: app)
    }
    private var editScreen: EditSheetScreen {
        EditSheetScreen(app: app)
    }
    
    override func setUp() {
        super.setUp()
        app = .init()
        app.launchArguments = [
            LaunchArgument.inMemoryPresistenStore.rawValue,
            LaunchArgument.setTestUserDefaults.rawValue
        ]
        app.launch()
    }
    
    override func tearDown() {
        app = nil
    }
    
    func test_AddingNewEntry() {
        // Given
        let editSheetInitialConfigurationExpectations = [
            editScreen.saveButton,
            editScreen.cancelButton,
            editScreen.datePicker,
            editScreen.startTimePicker,
            editScreen.finishTimePicker,
            editScreen.timeWorkedValueLabel,
            editScreen.breakTimeValueLabel,
            editScreen.overtimeValueLabel
        ].map { expectation(for: existsPredicate, evaluatedWith: $0) }
        
        // adjust test expectations to locale of the phone somehow?
        let cellExpetations = [
            app.staticTexts["06:00 - 14:30"],
            app.staticTexts["08 hours 30 min"]
        ].map { expectation(for: existsPredicate, evaluatedWith: $0) }
        
        navigateToHistoryView()
        // When
        historyScreen.addEntryButton.tap()
        // Then
        let initialConfig = XCTWaiter.wait(for: editSheetInitialConfigurationExpectations, timeout: standardTimeout)
        XCTAssertEqual(initialConfig, .completed, "Initial edit sheet should have all the components")
        
        // INFO: This test might be flaky depending on when it is called,
        // since pickers change when moving between days
        
        // When
        editScreen.startTimePicker.tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "06")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "00")
        editScreen.popoverDismissButton.tap()
        
        editScreen.finishTimePicker.tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "14")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "30")
        editScreen.popoverDismissButton.tap()
        
        // Then
        XCTAssertEqual(editScreen.timeWorkedValueLabel.label, "08:00")
        XCTAssertEqual(editScreen.overtimeValueLabel.label, "00:30")
        
        // When
        editScreen.saveButton.tap()
        
        // Then
        let cellResult = XCTWaiter.wait(for: cellExpetations, timeout: standardTimeout)
        XCTAssertEqual(cellResult, .completed)
    }
    
    #warning("Ensure setup includes a cell in the in memory store")
    func test_deletingEntry() {
        // Given
        navigateToHistoryView()
        let expectedCellCount = app.collectionViews.cells.count - 1
        let cellCountExpectation = expectation(
            for: NSPredicate(format: "count == \(expectedCellCount)"),
            evaluatedWith: app.collectionViews.cells
        )
        let swipeButtonsExpectation = [
            historyScreen.editEntryButton,
            historyScreen.deleteEntryButton
        ]
            .map { expectation(for: existsPredicate, evaluatedWith: $0) }
        
        let confirmDialogExpectations = [
            historyScreen.dialogOkButton,
            historyScreen.dialogCancelButton,
            historyScreen.dialogLabel
        ]
            .map { expectation(for: existsPredicate, evaluatedWith: $0) }
        
        // When
        app.collectionViews.cells.firstMatch.swipeLeft()
        let cellSwipeButtonsResult = XCTWaiter.wait(for: swipeButtonsExpectation, timeout: standardTimeout)
        
        // Then
        XCTAssertEqual(cellSwipeButtonsResult, .completed, "After swipe edit and delete buttons should exist")
        
        // When
        historyScreen.deleteEntryButton.tap()
        let confirmDialogResult = XCTWaiter.wait(for: confirmDialogExpectations, timeout: standardTimeout)
        
        // Then
        XCTAssertEqual(confirmDialogResult, .completed, "After pressing delete buttons confirm dialog should be present")
        
        // When
        app.buttons["Ok"].tap()
        
        // Then
        let result = XCTWaiter.wait(for: [cellCountExpectation], timeout: standardTimeout)
        XCTAssertEqual(result, .completed, "The amount of cells should be 1 less than starting amount")
    }
    
    func test_EditingExistingEntry() {
        // Given
        let resultExpetations = ["06:00 - 16:00", "10 hours 00 min"]
            .map{ app.staticTexts[$0] }
            .map { expectation(for: existsPredicate, evaluatedWith: $0) }
        navigateToHistoryView()
        // When
        app.collectionViews.cells.firstMatch.swipeLeft()
        historyScreen.editEntryButton.tap()
        editScreen.finishTimePicker.tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "16")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "00")
        editScreen.popoverDismissButton.tap()
        editScreen.saveButton.tap()
        
        // Then
        let result = XCTWaiter.wait(for: resultExpetations,
                                    timeout: standardTimeout)
        XCTAssertEqual(result, .completed,
                       "The expected static texts should exit")
    }
    
    private func navigateToHistoryView() {
        ContentViewScreen(app: app).tabBarHistoryButton.tap()
    }
}

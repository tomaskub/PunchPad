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
            expectation(for: existsPredicate, evaluatedWith: editScreen.saveButton),
            expectation(for: existsPredicate, evaluatedWith: editScreen.cancelButton),
            expectation(for: existsPredicate, evaluatedWith: editScreen.startDatePicker),
            expectation(for: existsPredicate, evaluatedWith: editScreen.finishDatePicker),
            expectation(for: existsPredicate, evaluatedWith: editScreen.timeWorkedValueLabel),
            expectation(for: existsPredicate, evaluatedWith: editScreen.overtimeValueLabel)
        ]
        let cellExpetations = [
            expectation(for: existsPredicate, evaluatedWith: app.staticTexts["6:00 AM"]),
            expectation(for: existsPredicate, evaluatedWith: app.staticTexts["2:30 PM"]),
            expectation(for: existsPredicate, evaluatedWith: app.staticTexts["08 hours 30 minutes"])
        ]
        navigateToHistoryView()
        // When
        historyScreen.addEntryButton.tap()
        // Then
        let initialConfig = XCTWaiter.wait(for: editSheetInitialConfigurationExpectations, timeout: standardTimeout)
        XCTAssertEqual(initialConfig, .completed, "Initial edit sheet should have all the components")
        // When
        editScreen.startDatePicker.buttons.element(boundBy: 1).tap()
        app.collectionViews.buttons.firstMatch.tap()
        editScreen.popoverDismissButton.tap()
        editScreen.startDatePicker.buttons.element(boundBy: 2).tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "6")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "00")
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "AM")
        editScreen.popoverDismissButton.tap()
        editScreen.finishDatePicker.buttons.element(boundBy: 1).tap()
        app.collectionViews.buttons.firstMatch.tap()
        editScreen.popoverDismissButton.tap()
        editScreen.finishDatePicker.buttons.element(boundBy: 2).tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "2")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "30")
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "PM")
        editScreen.popoverDismissButton.tap()
        // Then
        XCTAssertEqual(editScreen.timeWorkedValueLabel.label, "8.00")
        XCTAssertEqual(editScreen.overtimeValueLabel.label, "0.50")
        // When
        editScreen.saveButton.tap()
        app.collectionViews.cells.firstMatch.tap()
        // Then
        let cellResult = XCTWaiter.wait(for: cellExpetations, timeout: standardTimeout)
        XCTAssertEqual(cellResult, .completed)
    }
    
    func test_deletingEntry() {
        // Given
        navigateToHistoryView()
        let expectedCellCount = app.collectionViews.cells.count - 1
        let cellCountExpectation = expectation(for: NSPredicate(format: "count == \(expectedCellCount)"), evaluatedWith: app.collectionViews.cells)
        let swipeButtonsExpectation = [
            expectation(for: existsPredicate, evaluatedWith: historyScreen.editEntryButton),
            expectation(for: existsPredicate, evaluatedWith: historyScreen.deleteEntryButton)
        ]
        // When
        app.collectionViews.cells.firstMatch.swipeLeft()
        let cellSwipeButtonsResult = XCTWaiter.wait(for: swipeButtonsExpectation, timeout: standardTimeout)
        // Then
        XCTAssertEqual(cellSwipeButtonsResult, .completed, "After swipe edit and delete buttons should exist")
        // When
        historyScreen.deleteEntryButton.tap()
        // Then
        let result = XCTWaiter.wait(for: [cellCountExpectation], timeout: standardTimeout)
        XCTAssertEqual(result, .completed, "The amount of cells should be 1 less than starting amount")
    }
    
    func test_EditingExistingEntry() {
        // Given
        let resultExpetations = [
            expectation(for: existsPredicate, evaluatedWith: app.staticTexts["6:00 AM"]),
            expectation(for: existsPredicate, evaluatedWith: app.staticTexts["4:00 PM"]),
            expectation(for: existsPredicate, evaluatedWith: app.staticTexts["10 hours 00 minutes"])
        ]
        navigateToHistoryView()
        // When
        app.collectionViews.cells.firstMatch.swipeLeft()
        historyScreen.editEntryButton.tap()
        editScreen.finishDatePicker.buttons.element(boundBy: 2).tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "4")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "00")
        editScreen.popoverDismissButton.tap()
        editScreen.saveButton.tap()
        app.collectionViews.cells.firstMatch.tap()
        // Then
        let result = XCTWaiter.wait(for: resultExpetations, timeout: standardTimeout)
        XCTAssertEqual(result, .completed, "The expected static texts should exit")
    }
    
    private func navigateToHistoryView() {
        ContentViewScreen(app: app).tabBarHistoryButton.tap()
    }
}

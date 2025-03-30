//
//  SettingsViewUITests.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 19/09/2023.
//

import XCTest

final class SettingsViewUITests: XCTestCase {
    
    private let standardTimeout: Double = 2.5
    private var app: XCUIApplication!
    private let existsPredicate = NSPredicate(format: "exists == true")
    
    private var settingsScreen: SettingsViewScreen {
        SettingsViewScreen(app: app)
    }
    
    override func setUp() {
        super.setUp()
        app = .init()
        app.launchArguments = [
            LaunchArgument.setTestUserDefaults.rawValue,
            LaunchArgument.inMemoryPresistenStore.rawValue
        ]
        app.launch()
    }
    
    override func tearDown() {
        app = nil
    }
    
    func test_SettingsViewInitialScreenConfiguration() {
        // Given
        let notExpandedElementsExpectations = [
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.setTimeLengthExpandText),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.setOvertimeLengthExpandButton),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.keepLogginOvertimeToggle),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.grossPaycheckTextField),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.calculateNetPayToggle),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.clearAllSavedDataButton),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.resetPreferencesButton),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.sendNotificationsToggle),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.appearanceDarkButton),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.appearanceLightButton),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.appearanceSystemButton)
        ]
        let worktimePickerExpectations = [
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.workTimeHoursPicker),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.workMinutesHoursPicker)
        ]
        let overtimePickerExpectations = [
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.overtimeHoursPicker),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.overtimeMinutesPicker)
        ]
        navigateToSettingsView()
        // Then
        let notExpandedElementsResult = XCTWaiter.wait(for: notExpandedElementsExpectations, timeout: standardTimeout)
        XCTAssertEqual(notExpandedElementsResult, .completed, "Elements should exist")
        // When
        settingsScreen.setTimeLengthExpandText.tap()
        // Then
        let worktimePickerResult = XCTWaiter.wait(for: worktimePickerExpectations, timeout: standardTimeout)
        XCTAssertEqual(worktimePickerResult, .completed, "Work time pickers should exist")
        // When
        settingsScreen.setTimeLengthExpandText.tap()
        settingsScreen.setOvertimeLengthExpandButton.tap()
        // Then
        let overtimePickerResult = XCTWaiter.wait(for: overtimePickerExpectations, timeout: standardTimeout)
        XCTAssertEqual(overtimePickerResult, .completed, " Overtime pickers should exist")
    }
    
    func test_toggleButtonsToggleAndRetainValues() {
        // Given
        navigateToSettingsView()
        let initialValues: [String?] = [
            settingsScreen.sendNotificationsToggle.value as? String,
            settingsScreen.keepLogginOvertimeToggle.value as? String,
            settingsScreen.calculateNetPayToggle.value as? String
        ]
        // When
        settingsScreen.sendNotificationsToggle.switches.firstMatch.tap()
        settingsScreen.keepLogginOvertimeToggle.switches.firstMatch.tap()
        settingsScreen.calculateNetPayToggle.switches.firstMatch.tap()
        // Then
        let exitValues: [String?] = [
            settingsScreen.sendNotificationsToggle.value as? String,
            settingsScreen.keepLogginOvertimeToggle.value as? String,
            settingsScreen.calculateNetPayToggle.value as? String
        ]
        XCTAssertNotEqual(exitValues[0], initialValues[0])
        XCTAssertNotEqual(exitValues[1], initialValues[1])
        XCTAssertNotEqual(exitValues[2], initialValues[2])
        // When
        restartApp()
        navigateToSettingsView()
        // Then
        let resumeValues: [String?] = [
            settingsScreen.sendNotificationsToggle.value as? String,
            settingsScreen.keepLogginOvertimeToggle.value as? String,
            settingsScreen.calculateNetPayToggle.value as? String
        ]
        XCTAssertEqual(exitValues, resumeValues)
    }
    
    func test_pickersScrollAndRetainValues() {
        enum PickerKeys: String, CaseIterable {
            case worktimeHours, worktimeMinutes, overtimeHours, overtimeMinutes
        }
        // Given
        navigateToSettingsView()
        let expectedValues: [PickerKeys : String] = [
            .worktimeHours : "6",
            .worktimeMinutes : "10",
            .overtimeHours : "3",
            .overtimeMinutes : "20"]
        // When
        settingsScreen.setTimeLengthExpandText.tap()
        // Then
        var initialValues: [PickerKeys : String?] = [
            .worktimeHours : settingsScreen.workTimeHoursPicker.pickerWheels.firstMatch.value as? String,
            .worktimeMinutes : settingsScreen.workMinutesHoursPicker.pickerWheels.firstMatch.value as? String
        ]
        // When
        settingsScreen.workTimeHoursPicker.pickerWheels.firstMatch.adjust(toPickerWheelValue: expectedValues[.worktimeHours]!)
        settingsScreen.workMinutesHoursPicker.pickerWheels.firstMatch.adjust(toPickerWheelValue: expectedValues[.worktimeMinutes]!)
        settingsScreen.setTimeLengthExpandText.tap()
        settingsScreen.setOvertimeLengthExpandButton.tap()
        // Then
        initialValues.updateValue(settingsScreen.overtimeHoursPicker.pickerWheels.firstMatch.value as? String, forKey: .overtimeHours)
        initialValues.updateValue(settingsScreen.overtimeMinutesPicker.pickerWheels.firstMatch.value as? String, forKey: .overtimeMinutes)
        
        for key in PickerKeys.allCases {
            XCTAssertNotEqual(initialValues[key], expectedValues[key], "Initial and expected values should not be equal")
        }
        
        // When
        settingsScreen.overtimeHoursPicker.pickerWheels.firstMatch.adjust(toPickerWheelValue: expectedValues[.overtimeHours]!)
        settingsScreen.overtimeMinutesPicker.pickerWheels.firstMatch.adjust(toPickerWheelValue: expectedValues[.overtimeMinutes]!)
        settingsScreen.setOvertimeLengthExpandButton.tap()
        restartApp()
        navigateToSettingsView()
        settingsScreen.setTimeLengthExpandText.tap()
        // Then
        _ = settingsScreen.workTimeHoursPicker.waitForExistence(timeout: standardTimeout)
        XCTAssertEqual(expectedValues[.worktimeHours]!, settingsScreen.workTimeHoursPicker.pickerWheels.firstMatch.value as? String)
        XCTAssertEqual(expectedValues[.worktimeMinutes]!, settingsScreen.workMinutesHoursPicker.pickerWheels.firstMatch.value as? String)
        // When
        settingsScreen.setTimeLengthExpandText.tap()
        settingsScreen.setOvertimeLengthExpandButton.tap()
        // Then
        _ = settingsScreen.overtimeHoursPicker.waitForExistence(timeout: standardTimeout)
        XCTAssertEqual(expectedValues[.overtimeHours]!, settingsScreen.overtimeHoursPicker.pickerWheels.firstMatch.value as? String)
        XCTAssertEqual(expectedValues[.overtimeMinutes]!, settingsScreen.overtimeMinutesPicker.pickerWheels.firstMatch.value as? String)
    }
    
    func test_resetUserDefaults() {
        // Given
        let valuePredicate = NSPredicate(format: "value == '0'")
        let initialToggleValueExpectations = generateToggleExpecations(predicate: valuePredicate)
        let initialPickerWorkValueExpectations = generatePickerWorkExpectations(predicate: valuePredicate)
        let initialPickerOvertimeValueExpectations = generatePickerOvertimeExpectations(predicate: valuePredicate)
        let finalToggleValueExpectations = generateToggleExpecations(predicate: valuePredicate)
        let finalPickerWorkValueExpectations = generatePickerWorkExpectations(predicate: valuePredicate)
        let finalPickerOvertimeValueExpectations = generatePickerOvertimeExpectations(predicate: valuePredicate)
        navigateToSettingsView()
        // When
        settingsScreen.resetPreferencesButton.tap()
        // Then
        let initialTogglesResult = XCTWaiter.wait(for: initialToggleValueExpectations, timeout: standardTimeout)
        XCTAssertEqual(initialTogglesResult, .completed, "The toggles should have false value")
        XCTAssertEqual(settingsScreen.grossPaycheckTextField.value as? String, "0", "TextField should show '0'")
        // When
        settingsScreen.setTimeLengthExpandText.tap()
        // Then
        let initialWorkPickerResult = XCTWaiter.wait(for: initialPickerWorkValueExpectations, timeout: standardTimeout)
        XCTAssertEqual(initialWorkPickerResult, .completed, "The work time pickers should show 0s")
        // When
        settingsScreen.setTimeLengthExpandText.tap()
        settingsScreen.setOvertimeLengthExpandButton.tap()
        // Then
        let initialOvertimePickerResult = XCTWaiter.wait(for: initialPickerOvertimeValueExpectations, timeout: standardTimeout)
        XCTAssertEqual(initialOvertimePickerResult, .completed, "The overtime pickers should show 0s")
        // When
        restartApp()
        navigateToSettingsView()
        // Then
        let finalTogglesResult = XCTWaiter.wait(for: finalToggleValueExpectations, timeout: standardTimeout)
        XCTAssertEqual(finalTogglesResult, .completed, "The toggles should have false value")
        XCTAssertEqual(settingsScreen.grossPaycheckTextField.value as? String, "0", "TextField should be show '0'")
        // When
        settingsScreen.setTimeLengthExpandText.tap()
        // Then
        let finalWorkPickerResult = XCTWaiter.wait(for: finalPickerWorkValueExpectations, timeout: standardTimeout)
        XCTAssertEqual(finalWorkPickerResult, .completed, "The work time pickers should show 0s")
        // When
        settingsScreen.setTimeLengthExpandText.tap()
        settingsScreen.setOvertimeLengthExpandButton.tap()
        // Then
        let finalOvertimePickerResult = XCTWaiter.wait(for: finalPickerOvertimeValueExpectations, timeout: standardTimeout)
        XCTAssertEqual(finalOvertimePickerResult, .completed, "The overtime pickers should show 0s")
    }
    
    func test_ClearSavedData() {
        // Given
        navigateToSettingsView()
        let emptyStateLabel = HistoryViewScreen(app: app).emptyStateLabel
        
        // When
        settingsScreen.clearAllSavedDataButton.tap()
        settingsScreen.navigationBackButtons.tap()
        navigateToHistoryView()
        
        // Then
        let expectation = expectation(for: existsPredicate, evaluatedWith: emptyStateLabel)
        let result = XCTWaiter.wait(for: [expectation], timeout: standardTimeout)
        XCTAssertEqual(result, .completed, "There should be no cells in app")
    }
    
    private func restartApp() {
        app.terminate()
        app = nil
        app = .init()
        app.launch()
    }
    
    private func navigateToSettingsView() {
        ContentViewScreen(app: app).navBarSettingsButton.tap()
    }
    
    private func navigateToHistoryView() {
        ContentViewScreen(app: app).tabBarHistoryButton.tap()
    }
}

// MARK: EXPECTATION GENERATOR FUNCTIONS
extension SettingsViewUITests {
    private func generateToggleExpecations(predicate: NSPredicate) -> [XCTestExpectation] {
        [expectation(for: predicate, evaluatedWith: settingsScreen.sendNotificationsToggle),
         expectation(for: predicate, evaluatedWith: settingsScreen.keepLogginOvertimeToggle),
         expectation(for: predicate, evaluatedWith: settingsScreen.calculateNetPayToggle)]
    }
    
    private func generatePickerWorkExpectations(predicate: NSPredicate) -> [XCTestExpectation] {
        [expectation(for: predicate, evaluatedWith: settingsScreen.workTimeHoursPicker.pickerWheels.firstMatch),
         expectation(for: predicate, evaluatedWith: settingsScreen.workMinutesHoursPicker.pickerWheels.firstMatch)]
    }
    
    func generatePickerOvertimeExpectations(predicate: NSPredicate) -> [XCTestExpectation] {
        [expectation(for: predicate, evaluatedWith: settingsScreen.overtimeHoursPicker.pickerWheels.firstMatch),
         expectation(for: predicate, evaluatedWith: settingsScreen.overtimeMinutesPicker.pickerWheels.firstMatch)]
    }
}

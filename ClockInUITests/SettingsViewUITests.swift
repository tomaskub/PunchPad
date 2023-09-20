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
            LaunchArgument.setTestUserDefaults.rawValue
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
    
    func test_toggleButtonsRetainValues() {
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
        app.terminate()
        app = nil
        app = .init()
        app.launch()
        navigateToSettingsView()
        // Then
        let resumeValues: [String?] = [
            settingsScreen.sendNotificationsToggle.value as? String,
            settingsScreen.keepLogginOvertimeToggle.value as? String,
            settingsScreen.calculateNetPayToggle.value as? String
        ]
        XCTAssertEqual(exitValues, resumeValues)
    }
    
    private func navigateToSettingsView() {
        HomeViewScreen(app: app).settingsNavigationButton.tap()
    }
}

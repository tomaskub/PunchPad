//
//  OnboardingUITests.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 02/09/2023.
//

import XCTest

final class OnboardingUITests: XCTestCase {
    
    private let standardTimeout: Double = 2.5
    private var app: XCUIApplication!
    
    private let existsPredicate = NSPredicate(format: "exists == true")
    private let notExistPredicate = NSPredicate(format: "exists == false")
    
    private var onboardingScreen: OnboardingViewScreen {
        OnboardingViewScreen(app: app)
    }
    private var settingsScreen: SettingsViewScreen {
        SettingsViewScreen(app: app)
    }
    
    override func setUp() {
        super.setUp()
        app = .init()
        app.launchArguments = [
            LaunchArgument.withOnboarding.rawValue
        ]
        app.launch()
    }
    
    override func tearDown() {
        app = nil
    }
    
    func test_OnboardingInitialScreensConfiguration() {
        // Given
        let zeroStageExpectations = [
            expectation(for: existsPredicate, evaluatedWith: onboardingScreen.advanceStageButton),
            expectation(for: notExistPredicate, evaluatedWith: onboardingScreen.regressStageButton)
        ]
        let firstStageExpectations = [
            expectation(for: existsPredicate, evaluatedWith: onboardingScreen.workingHoursPicker),
            expectation(for: existsPredicate, evaluatedWith: onboardingScreen.workingMinutesPicker),
            expectation(for: existsPredicate, evaluatedWith: onboardingScreen.regressStageButton),
            expectation(for: existsPredicate, evaluatedWith: onboardingScreen.advanceStageButton)
        ]
        let secondStageExpectations = [
            expectation(for: existsPredicate, evaluatedWith: onboardingScreen.overtimeToggleButton),
            expectation(for: notExistPredicate, evaluatedWith: onboardingScreen.overtimeHoursPicker),
            expectation(for: notExistPredicate, evaluatedWith: onboardingScreen.overtimeMinutesPicker),
            expectation(for: existsPredicate, evaluatedWith: onboardingScreen.regressStageButton)
        ]
        let thirdStageExpectations = [
            expectation(for: existsPredicate, evaluatedWith: onboardingScreen.notificationToggleButton),
            expectation(for: existsPredicate, evaluatedWith: onboardingScreen.regressStageButton)
        ]
        let fourthStageExpectations = [
            expectation(for: existsPredicate, evaluatedWith: onboardingScreen.grossPaycheckTextField),
            expectation(for: existsPredicate, evaluatedWith: onboardingScreen.calculateNetSalaryToggleButton),
            expectation(for: existsPredicate, evaluatedWith: onboardingScreen.regressStageButton)
        ]
        // Then
        let initialStageResult = XCTWaiter.wait(for: zeroStageExpectations, timeout: standardTimeout)
        XCTAssertEqual(initialStageResult, .completed, "Advance stage button should exist")
        // When
        onboardingScreen.advanceStageButton.tap()
        // Then
        let firstStageResult = XCTWaiter.wait(for: firstStageExpectations, timeout: standardTimeout)
        XCTAssertEqual(firstStageResult, .completed, "First stage elements should exist")
        // When
        onboardingScreen.advanceStageButton.tap()
        // Then
        let secondStageResult = XCTWaiter.wait(for: secondStageExpectations, timeout: standardTimeout)
        XCTAssertEqual(secondStageResult, .completed, "Second stage elements should exist")
        // When
        onboardingScreen.advanceStageButton.tap()
        // Then
        let thirdStageResult = XCTWaiter.wait(for: thirdStageExpectations, timeout: standardTimeout)
        XCTAssertEqual(thirdStageResult, .completed, "Third stage elements should exist")
        // When
        onboardingScreen.advanceStageButton.tap()
        // Then
        let fourthStageResult = XCTWaiter.wait(for: fourthStageExpectations, timeout: standardTimeout)
        XCTAssertEqual(fourthStageResult, .completed, "Fourth stage elements should exist")
    }
    
    func test_OnboardingUserFlow() {
        // Given
        let overtimePickersExpectations = [
            expectation(for: existsPredicate, evaluatedWith: onboardingScreen.overtimeHoursPicker),
            expectation(for: existsPredicate, evaluatedWith: onboardingScreen.overtimeMinutesPicker)
        ]
        let settingsPickersExistanceExpectation = [
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.workTimeHoursPicker),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.workMinutesHoursPicker),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.overtimeHoursPicker),
            expectation(for: existsPredicate, evaluatedWith: settingsScreen.overtimeMinutesPicker)
        ]
        // When
        onboardingScreen.advanceStageButton.tap()
        onboardingScreen.workingMinutesPicker.children(matching: .pickerWheel).firstMatch.adjust(toPickerWheelValue: "30")
        onboardingScreen.workingHoursPicker.children(matching: .pickerWheel).firstMatch.adjust(toPickerWheelValue: "7")
        onboardingScreen.advanceStageButton.tap()
        onboardingScreen.overtimeToggleButton.switches.firstMatch.tap()
        // Then
        let result = XCTWaiter.wait(for: overtimePickersExpectations, timeout: standardTimeout)
        XCTAssertEqual(result, .completed, "After overtime toggles is set to true, overtime hours and minutes pickers should exist")
        // When
        onboardingScreen.overtimeHoursPicker.children(matching: .pickerWheel).firstMatch.adjust(toPickerWheelValue: "4")
        onboardingScreen.overtimeMinutesPicker.children(matching: .pickerWheel).firstMatch.adjust(toPickerWheelValue: "30")
        onboardingScreen.advanceStageButton.tap()
        onboardingScreen.notificationToggleButton.switches.firstMatch.tap()
        onboardingScreen.advanceStageButton.tap()
        onboardingScreen.grossPaycheckTextField.tap()
        onboardingScreen.grossPaycheckTextField.typeText("10000\n")
        onboardingScreen.calculateNetSalaryToggleButton.switches.firstMatch.tap()
        onboardingScreen.advanceStageButton.tap(withNumberOfTaps: 2, numberOfTouches: 1)
        HomeViewScreen(app: app).settingsNavigationButton.tap()
        // Then
        XCTAssertEqual(settingsScreen.grossPaycheckTextField.value as! String, "10000")
        XCTAssertEqual(settingsScreen.calculateNetPayToggle.value as? String, "1")
        XCTAssertEqual(settingsScreen.sendNotificationsToggle.value as? String, "1")
        XCTAssertEqual(settingsScreen.keepLogginOvertimeToggle.value as? String, "1")
        // When
        settingsScreen.setTimeLengthExpandText.tap()
        settingsScreen.setOvertimeLengthExpandButton.tap()
        // Then
        _ = XCTWaiter.wait(for: settingsPickersExistanceExpectation, timeout: standardTimeout)
        XCTAssertEqual(settingsScreen.workTimeHoursPicker.pickerWheels.firstMatch.value as! String, "7")
        XCTAssertEqual(settingsScreen.workMinutesHoursPicker.pickerWheels.firstMatch.value as! String, "30")
        XCTAssertEqual(settingsScreen.overtimeHoursPicker.pickerWheels.firstMatch.value as! String, "4")
        XCTAssertEqual(settingsScreen.overtimeMinutesPicker.pickerWheels.firstMatch.value as! String, "30")
    }
}

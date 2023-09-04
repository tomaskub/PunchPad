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
    
    override func setUp() {
        super.setUp()
        app = .init()
        app.launchArguments = [
            "-withOnboarding"
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
}

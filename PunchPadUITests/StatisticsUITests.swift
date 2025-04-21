//
//  StatisticsUITests.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 10/09/2023.
//

import DomainModels
import XCTest

final class StatisticsUITests: XCTestCase {
    
    private let existsPredicate = NSPredicate(format: "exists == true")
    private let standardTimeout: Double = 2.5
    private var app: XCUIApplication!
    
    private var statisticsScreen: StatisticsViewScreen {
        StatisticsViewScreen(app: app)
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
    
    func test_initialScreenElements() {
        // Given
        let initialConfigurationExpectations = [
            statisticsScreen.salaryCalculationSectionHeader,
            statisticsScreen.allRangeSegmentedButton,
            statisticsScreen.weekRangeSegmentedButton,
            statisticsScreen.monthRangeSegmentedButton,
        ]
            .map { expectation(for: existsPredicate, evaluatedWith: $0) }
        let swipeUpExpectations = [
            statisticsScreen.grossPayLabel,
            statisticsScreen.grossPayPerHourLabel,
            statisticsScreen.periodLabel,
            statisticsScreen.workDaysNumberLabel
        ]
            .map { expectation(for: existsPredicate, evaluatedWith: $0) }

        // When
        navigateToStatisticsView()
        
        // Then
        let initialConfigurationResult = XCTWaiter.wait(for: initialConfigurationExpectations, timeout: standardTimeout)
        XCTAssertEqual(initialConfigurationResult, .completed, "Initial components should exist")
        
        // When
        statisticsScreen.salaryCalculationSectionHeader.swipeUp()
        
        // Then
        let swipeUpResult = XCTWaiter.wait(for: swipeUpExpectations, timeout: standardTimeout)
        XCTAssertEqual(swipeUpResult, .completed, "Initial components should exist")
    }
    
    private func navigateToStatisticsView() {
        ContentViewScreen(app: app).tabBarStatisticsButton.tap()
    }
}

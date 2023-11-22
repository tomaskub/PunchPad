//
//  StatisticsUITests.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 10/09/2023.
//

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
    
    func test_ChartConfiguration() {
        // Given
        let initialConfigurationExpectations = [
            expectation(for: existsPredicate, evaluatedWith: statisticsScreen.chartSectionHeader),
            expectation(for: existsPredicate, evaluatedWith: statisticsScreen.salaryCalculationSectionHeader),
            expectation(for: existsPredicate, evaluatedWith: statisticsScreen.detailedHistoryNavigationButton),
            expectation(for: existsPredicate, evaluatedWith: statisticsScreen.workTimeChart),
        ]
        // When
        navigateToStatisticsView()
        // Then
        let initialConfigurationResult = XCTWaiter.wait(for: initialConfigurationExpectations, timeout: standardTimeout)
        XCTAssertEqual(initialConfigurationResult, .completed, "Initial components should exist")
        // When
        statisticsScreen.startTimeChartButton.tap()
        // Then
        let startTimeChartExistance = statisticsScreen.startTimeChart.waitForExistence(timeout: standardTimeout)
        XCTAssert(startTimeChartExistance, "Start time chart should exist")
        // When
        statisticsScreen.finishTimeChartButton.tap()
        // Then
        let finishTimeChartExistance = statisticsScreen.finishTimeChart.waitForExistence(timeout: standardTimeout)
        XCTAssert(finishTimeChartExistance, "Finish time chart should exist")
        // When
        statisticsScreen.workTimeChartButton.tap()
        // Then
        let workTimeChartExistance = statisticsScreen.workTimeChart.waitForExistence(timeout: standardTimeout)
        XCTAssert(workTimeChartExistance, "Work time chart should exist")
    }
    
    private func navigateToStatisticsView() {
        ContentViewScreen(app: app).tabBarStatisticsButton.tap()
    }
}

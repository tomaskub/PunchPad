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
    
    private func navigateToStatisticsView() {
        HomeViewScreen(app: app).statisticsNavigationButton.tap()
    }
}

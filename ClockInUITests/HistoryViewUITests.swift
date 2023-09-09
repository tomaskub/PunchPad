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
    
    override func setUp() {
        super.setUp()
        app = .init()
        app.launchArguments = [
            
        ]
        app.launch()
    }
    
    override func tearDown() {
        app = nil
    }
    
    private func navigateToHistoryView() {
        HomeViewScreen(app: app).statisticsNavigationButton.tap()
        StatisticsViewScreen(app: app).detailedHistoryNavigationButton.tap()
    }
}

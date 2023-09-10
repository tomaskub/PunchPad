//
//  HomeViewScreen.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 02/09/2023.
//

import XCTest

class HomeViewScreen {
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var timerStartStopButton: XCUIElement {
        app.buttons[ScreenIdentifier.HomeView.startStopButton.rawValue]
    }
    
    var timerResumePauseButton: XCUIElement {
        app.buttons[ScreenIdentifier.HomeView.resumePauseButton.rawValue]
    }
    
    var timerLabel: XCUIElement {
        app.buttons.staticTexts[ScreenIdentifier.HomeView.timerLabel.rawValue]
    }
    
    var statisticsNavigationButton: XCUIElement {
        app.buttons[ScreenIdentifier.HomeView.statisticsNavigationButton.rawValue]
    }
    
    var settingsNavigationButton: XCUIElement {
        app.buttons[ScreenIdentifier.HomeView.settingNavigationButton.rawValue]
    }
}

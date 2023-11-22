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
    
    var timerStartPauseButton: XCUIElement {
        app.buttons[ScreenIdentifier.HomeView.startPauseButton.rawValue]
    }
    
    var timerFinishButton: XCUIElement {
        app.buttons[ScreenIdentifier.HomeView.finishButton.rawValue]
    }
    
    var timerLabel: XCUIElement {
        app.buttons.staticTexts[ScreenIdentifier.HomeView.timerLabel.rawValue]
    }
    
    var settingsNavigationButton: XCUIElement {
        app.buttons[ScreenIdentifier.HomeView.settingNavigationButton.rawValue]
    }
}

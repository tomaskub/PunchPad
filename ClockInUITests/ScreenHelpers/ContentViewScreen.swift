//
//  ContentViewScreen.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 22/11/2023.
//

import XCTest

class ContentViewScreen {
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var tabBarHomeButton: XCUIElement {
        app.tabBars.buttons[ScreenIdentifier.TabBar.home.rawValue]
    }
    
    var tabBarStatisticsButton: XCUIElement {
        app.tabBars.buttons[ScreenIdentifier.TabBar.statistics.rawValue]
    }
    var tabBarHistoryButton: XCUIElement {
        app.tabBars.buttons[ScreenIdentifier.TabBar.history.rawValue]
    }
}

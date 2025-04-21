//
//  ContentViewScreen.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 22/11/2023.
//

import DomainModels
import XCTest

class ContentViewScreen {
    private typealias Elements = ScreenIdentifier.NavigationElements
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var tabBarHomeButton: XCUIElement {
        app.staticTexts[Elements.TabBarButtons.home.rawValue]
    }
    
    var tabBarStatisticsButton: XCUIElement {
        app.staticTexts[Elements.TabBarButtons.statistics.rawValue]
    }
    
    var tabBarHistoryButton: XCUIElement {
        app.staticTexts[Elements.TabBarButtons.history.rawValue]
    }
    
    var navBarSettingsButton: XCUIElement {
        app.images[Elements.NavigationBarButtons.settingNavigationButton.rawValue]
    }
}

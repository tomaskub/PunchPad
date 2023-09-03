//
//  OnboardingUITests.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 02/09/2023.
//

import XCTest

final class OnboardingUITests: XCTestCase {
    private var app: XCUIApplication!
    
    private var onbardingScreen: OnboardingViewScreen {
        OnboardingViewScreen(app: app)
    }
    
    override func setUp() {
        super.setUp()
        app = .init()
        app.launch()
    }
    
    override func tearDown() {
        app = nil
    }
}

//
//  ClockInUITests.swift
//  ClockInUITests
//
//  Created by Tomasz Kubiak on 3/27/23.
//

import XCTest
@testable import PunchPad

final class ClockInUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = .init()
        app.launch()
    }
    
    override func tearDown() {
        app = nil
    }
}

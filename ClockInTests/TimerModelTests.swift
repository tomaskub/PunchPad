//
//  TimerModelTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/12/23.
//

import XCTest
@testable import ClockIn

final class TimerModelTests: XCTestCase {
    
    var sut: TimerModel!
    
    override func setUp() {
        super.setUp()
        sut = .init(TimerModel(dataManager: DataManager.testing, timerProvider: MockTimer.self))
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testUpdateTimer_whenCountSecondsSmallerThanSubtrahend() throws {
//        sut.isStarted = true
//        sut.isRunning = true
        
        sut.startTimer()
        for _ in 0...9 {
            MockTimer.currentTimer.fire()
        }
        let valuePredictedAfterOneFire: CGFloat = 1 - CGFloat(sut.timerTotalSeconds - 10) / CGFloat (sut.timerTotalSeconds)
        XCTAssertEqual(sut.progress, valuePredictedAfterOneFire, "Timer should fire once")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

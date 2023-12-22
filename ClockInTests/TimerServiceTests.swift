//
//  TimerServiceTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 22/12/2023.
//

import XCTest
@testable import ClockIn

final class TimerServiceTests: XCTestCase {
    var sut: TimerService!
    
    let timerLimit = 180
    let timerSecondLimit = 60
    
    override func setUp() {
        super.setUp()
        sut = .init(timerProvider: MockTimer.self,
                    timerLimit: TimeInterval(timerLimit),
                    timerSecondLimit: TimeInterval(timerSecondLimit),
                    progressAfterLimit: true)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testUpdateTimer_firstCounter() {
        // Given
        let numberOfFires = 10
        let expectedCounterValue: TimeInterval = TimeInterval(timerLimit - numberOfFires)
        //When
        sut.startTimer()
        for _ in 0...numberOfFires - 1 {
            MockTimer.currentTimer.fire()
        }
        //Then
        XCTAssertEqual(sut.firstCounter, expectedCounterValue, "Counter value should be equal to predicted value")
    }
    
    func testUpdateTimer_secondCounter() {
        let numberOfFires = timerLimit + 10
        let expectedSecondCounterValue = TimeInterval(integerLiteral: 10)
        //When
        sut.startTimer()
        for _ in 0...numberOfFires - 1 {
            MockTimer.currentTimer.fire()
        }
        //Then
        XCTAssertEqual(expectedSecondCounterValue, sut.secondCounter, "Counter value should be equal to predicted value")
    }
}

//
//  TimerModelTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/12/23.
//

import XCTest
@testable import ClockIn

final class TimerModelTests: XCTestCase {
    
    var sut: HomeViewModel!
    
    override func setUp() {
        super.setUp()
        sut = .init(HomeViewModel(dataManager: DataManager.testing, timerProvider: MockTimer.self))
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
    
    func testUpdateTimer_whenCountSecondsBiggerThanSubtrahendAndNoOvertimeAllowed() throws {
        sut.progressAfterFinish = false
        sut.startTimer()
        
        for _ in 0...sut.timerTotalSeconds {
            
                MockTimer.currentTimer.fire()
            
        }
        XCTAssertFalse(MockTimer.currentTimer.isValid, "Timer should be invalid")
        XCTAssertEqual(sut.progress, 1, "Progress should be equal to 1")
    }
    
    func testUpdateTimer_whenCountSecondsBiggerThanSubtrahendAndOvertimeAllowed() throws {
        sut.progressAfterFinish = true
        sut.startTimer()
        
        for _ in 0...sut.timerTotalSeconds + 9  {
            
                MockTimer.currentTimer.fire()
            
        }
        let valuePredicted: CGFloat = CGFloat(10) / CGFloat (sut.overtimeTotalSeconds)
        print(MockTimer.currentTimer.isValid)
        XCTAssertTrue(MockTimer.currentTimer.isValid, "Timer should be valid")
        XCTAssertEqual(sut.progress, 1, "Progress should be equal to 1")
        XCTAssertEqual(sut.overtimeProgress, valuePredicted, "overtimeProgress should be equal to predicted value")
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

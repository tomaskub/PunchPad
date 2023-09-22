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
    var settingsStore: SettingsStore!
    
    override func setUp() {
        super.setUp()
        SettingsStore.setTestUserDefaults()
        self.settingsStore = SettingsStore()
        sut = .init(HomeViewModel(dataManager: DataManager.testing, settingsStore: settingsStore, timerProvider: MockTimer.self))
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testUpdateTimer_whenCountSecondsSmallerThanSubtrahend() throws {
        sut.startTimer()
        for _ in 0...9 {
            MockTimer.currentTimer.fire()
        }
        let valuePredictedAfterOneFire: CGFloat = 1 - CGFloat(settingsStore.workTimeInSeconds - 10) / CGFloat (settingsStore.workTimeInSeconds)
        XCTAssertEqual(sut.progress, valuePredictedAfterOneFire, "Timer should fire once")
    }
    
    func testUpdateTimer_whenCountSecondsBiggerThanSubtrahendAndNoOvertimeAllowed() throws {
        sut.progressAfterFinish = false
        sut.startTimer()
        for _ in 0...settingsStore.workTimeInSeconds {
                MockTimer.currentTimer.fire()
        }
        XCTAssertFalse(MockTimer.currentTimer.isValid, "Timer should be invalid")
        XCTAssertEqual(sut.progress, 1, "Progress should be equal to 1")
    }
    
    func testUpdateTimer_whenCountSecondsBiggerThanSubtrahendAndOvertimeAllowed() throws {
        sut.progressAfterFinish = true
        sut.startTimer()
        for _ in 0...settingsStore.workTimeInSeconds + 9  {
                MockTimer.currentTimer.fire()
        }
        let valuePredicted: CGFloat = CGFloat(10) / CGFloat (settingsStore.maximumOvertimeAllowedInSeconds)
        print(MockTimer.currentTimer.isValid)
        XCTAssertTrue(MockTimer.currentTimer.isValid, "Timer should be valid")
        XCTAssertEqual(sut.progress, 1, "Progress should be equal to 1")
        XCTAssertEqual(sut.overtimeProgress, valuePredicted, "overtimeProgress should be equal to predicted value")
        
    }
}

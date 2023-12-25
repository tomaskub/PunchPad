//
//  TimerModelTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/12/23.
//

import XCTest
@testable import ClockIn

final class HomeViewModelModelTests: XCTestCase {
    
    var sut: HomeViewModel!
    var settingsStore: SettingsStore!
    var workTimerLimit: Int = 100
    
    override func setUp() {
        super.setUp()
        SettingsStore.setTestUserDefaults()
        self.settingsStore = SettingsStore()
        DataManager.testing.deleteAll()
        sut = .init(HomeViewModel(dataManager: DataManager.testing,
                                  settingsStore: settingsStore,
                                  payManager: PayManager(dataManager: DataManager.testing, settingsStore: settingsStore),
                                  timerProvider: MockTimer.self)
        )
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func test_startTimerService_when_noOvertime_firstRun() {
        //Given
        setUpWithOneTimer()
        //When
        sut.startTimerService()
        //Then
        XCTAssertEqual(sut.state, .running, "State should be equal to `running`")
    }

    func test_timerProperties_updateWhenRunning() {
        //Given
        let numberOfFires = 10
        let expectedNormalProgressValue = CGFloat(numberOfFires) / CGFloat(workTimerLimit)
        let expectedOvertimeProgressValue = CGFloat(0)
        setUpWithOneTimer()
        //When
        sut.startTimerService()
        fireTimer(10)
        //Then
        XCTAssertEqual(sut.timerDisplayValue, TimeInterval(numberOfFires), "Timer display value should be equal to 10")
        XCTAssertEqual(sut.normalProgress, expectedNormalProgressValue, "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(sut.overtimeProgress, expectedOvertimeProgressValue, "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }

    func test_timerProperties_notUpdating_whenPaused() {
        //Given
        setUpWithOneTimer()
        //When
        sut.startTimerService()
        fireTimer(10)
        sut.pauseTimerService()
        fireTimer(10)
        //Then
        XCTAssertEqual(sut.timerDisplayValue, TimeInterval(integerLiteral: 10), "Timer display value should be equal to 10")
        XCTAssertEqual(sut.normalProgress, CGFloat(0.1), "Normal progress should be equal to 0.1")
        XCTAssertEqual(sut.overtimeProgress, CGFloat(0), "Overtime progress should be equal to 0")
    }

    func test_resumeTimerService_whenPaused() {
        //Given
        let numberOfFires = 10
        let expectedNormalProgressValue = CGFloat(2 * numberOfFires) / CGFloat(workTimerLimit)
        let expectedOvertimeProgressValue = CGFloat(0)
        setUpWithOneTimer()
        //When
        sut.startTimerService()
        fireTimer(10)
        sut.pauseTimerService()
        sut.resumeTimerService()
        fireTimer(10)
        //Then
        XCTAssertEqual(sut.timerDisplayValue, TimeInterval(2 * numberOfFires), "Timer display value should be equal to \(2 * numberOfFires)")
        XCTAssertEqual(sut.normalProgress, expectedNormalProgressValue, "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(sut.overtimeProgress, expectedOvertimeProgressValue, "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }

    func test_resumeFromBackground_when_timerServiceWasStarted() {
        //Given
        let numberOfSecondsPassedInBackground = 10
        let expectedDisplayValue = TimeInterval(numberOfSecondsPassedInBackground)
        let expectedNormalProgressValue = CGFloat(numberOfSecondsPassedInBackground) / CGFloat(workTimerLimit)
        let expectedOvertimeProgressValue = CGFloat(0)
        var enterBackgroundDate: Date = {
            Calendar.current.date(byAdding: .second, value: -numberOfSecondsPassedInBackground, to: Date())!
        }()
        setUpWithOneTimer()
        //When
        sut.startTimerService()
        sut.resumeFromBackground(enterBackgroundDate)
        //Then
        XCTAssertEqual(sut.timerDisplayValue, expectedDisplayValue, accuracy: 0.01, "Timer display value should be equal to \(expectedDisplayValue)")
        XCTAssertEqual(sut.normalProgress, expectedNormalProgressValue, accuracy: 0.01, "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(sut.overtimeProgress, expectedOvertimeProgressValue, accuracy: 0.01, "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }
    
    func test_resumeFromBackground_when_timerServiceWasNotStarted() {
        //Given
        let numberOfSecondsPassedInBackground = 10
        let expectedDisplayValue = TimeInterval(0)
        let expectedNormalProgressValue = CGFloat(0)
        let expectedOvertimeProgressValue = CGFloat(0)
        var enterBackgroundDate: Date = {
            Calendar.current.date(byAdding: .second, value: -numberOfSecondsPassedInBackground, to: Date())!
        }()
        setUpWithOneTimer()
        //When
        sut.resumeFromBackground(enterBackgroundDate)
        //Then
        XCTAssertEqual(sut.timerDisplayValue, expectedDisplayValue, accuracy: 0.01, "Timer display value should be equal to \(numberOfSecondsPassedInBackground)")
        XCTAssertEqual(sut.normalProgress, expectedNormalProgressValue, accuracy: 0.01, "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(sut.overtimeProgress, expectedOvertimeProgressValue, accuracy: 0.01, "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }

    func test_stopTimerService_stopsServiceAndSavesEntry() {
        //Given
        let numberOfExistingEntries = DataManager.testing.entryArray.count
        let numberOfFires = 10
        setUpWithOneTimer()
        //When
        sut.startTimerService()
        fireTimer(numberOfFires)
        sut.stopTimerService()
        //Then
        XCTAssertEqual(sut.state, .notStarted, "Service state should be not started")
        XCTAssertEqual(DataManager.testing.entryArray.count, numberOfExistingEntries + 1, "Additional entry should be saved")
    }
    
    private func setUpWithOneTimer() {
        settingsStore.isLoggingOvertime = false
        settingsStore.workTimeInSeconds = workTimerLimit
        sut = .init(HomeViewModel(dataManager: DataManager.testing,
                                  settingsStore: settingsStore,
                                  payManager: PayManager(dataManager: DataManager.testing, settingsStore: settingsStore),
                                  timerProvider: MockTimer.self)
        )
    }
    
    private func fireTimer(_ numberOfFires: Int) {
        for _ in 0...numberOfFires - 1 {
            MockTimer.currentTimer.fire()
        }
    }
}

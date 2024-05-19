//
//  TimerManagerTests.swift
//  PunchPadTests
//
//  Created by Tomasz Kubiak on 18/05/2024.
//

import XCTest
@testable import PunchPad

final class TimerManagerTests: XCTestCase {
    var sut: TimerManager!
    var workTimerLimit: Int = 100
    var overtimeTimerLimit: Int = 100
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}

//MARK: TIMER STATE CHANGE FUNCTIONS
extension TimerManagerTests {
    func test_startTimerService_when_noOvertime_firstRun() {
        //Given
        let expectedState: TimerServiceState = .running
        setUpWithOneTimer()
        //When
        sut.startTimerService()
        //Then
        XCTAssertEqual(sut.state, expectedState, "State should be equal to \(expectedState)")
    }
    
    func test_startTimerService_when_noOvertime_secondRun() {
        //Given
        let expectedState: TimerServiceState = .running
        let expectedProgress = CGFloat(0.2)
        let expectedDisplayValue = TimeInterval(integerLiteral: 20)
        setUpWithOneTimer()
        //When
        sut.startTimerService()
        fireTimer(10)
        sut.stopTimerService()
        sut.startTimerService()
        fireTimer(20)
        //Then
        XCTAssertEqual(sut.state, expectedState, "State should be equal to \(expectedState)")
        XCTAssertEqual(sut.workTimerService.progress, expectedProgress)
        XCTAssertEqual(sut.workTimerService.counter, expectedDisplayValue)
    }
    
    func test_timerProperties_updateWhenRunning_noOvertime() {
        //Given
        let numberOfFires = 10
        let expectedNormalProgressValue = CGFloat(numberOfFires) / CGFloat(workTimerLimit)
        setUpWithOneTimer()
        //When
        sut.startTimerService()
        fireTimer(10)
        //Then
        XCTAssertEqual(sut.workTimerService.counter,
                       TimeInterval(numberOfFires),
                       "Timer display value should be equal to 10")
        XCTAssertEqual(sut.workTimerService.progress, 
                       expectedNormalProgressValue,
                       "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertNil(sut.overtimeTimerService,
                     "Overtime service should be nil")
    }
    
    func test_timerProperties_notUpdating_whenPaused_noOvertime() {
        //Given
        setUpWithOneTimer()
        //When
        sut.startTimerService()
        fireTimer(10)
        sut.pauseTimerService()
        fireTimer(10)
        //Then
        XCTAssertEqual(sut.workTimerService.counter,
                       TimeInterval(integerLiteral: 10),
                       "Timer display value should be equal to 10")
        XCTAssertEqual(sut.workTimerService.progress,
                       CGFloat(0.1),
                       "Normal progress should be equal to 0.1")
        XCTAssertNil(sut.overtimeTimerService,
                     "Overtime timer service should be nil")
    }
    
    func test_resumeTimerService_whenPaused_noOvertime() {
        //Given
        let numberOfFires = 10
        let expectedNormalProgressValue = CGFloat(2 * numberOfFires) / CGFloat(workTimerLimit)
        setUpWithOneTimer()
        //When
        sut.startTimerService()
        fireTimer(10)
        sut.pauseTimerService()
        sut.resumeTimerService()
        fireTimer(10)
        //Then
        XCTAssertEqual(sut.workTimerService.counter, 
                       TimeInterval(2 * numberOfFires),
                       "Timer display value should be equal to \(2 * numberOfFires)")
        XCTAssertEqual(sut.workTimerService.progress, 
                       expectedNormalProgressValue,
                       "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertNil(sut.overtimeTimerService,
                     "Overtime  timer service should be nil")
    }
    
    func test_resumeFromBackground_when_timerServiceWasStarted_noOvertime() {
        //Given
        let numberOfSecondsPassedInBackground = 10
        let expectedDisplayValue = TimeInterval(numberOfSecondsPassedInBackground)
        let expectedNormalProgressValue = CGFloat(numberOfSecondsPassedInBackground) / CGFloat(workTimerLimit)
        var enterBackgroundDate: Date {
            Calendar.current.date(byAdding: .second, value: -numberOfSecondsPassedInBackground, to: Date())!
        }
        setUpWithOneTimer()
        //When
        sut.startTimerService()
        sut.resumeFromBackground(enterBackgroundDate)
        //Then
        XCTAssertEqual(sut.workTimerService.counter,
                       expectedDisplayValue,
                       accuracy: 0.01,
                       "Counter value should be equal to \(expectedDisplayValue)")
        XCTAssertEqual(sut.workTimerService.progress,
                       expectedNormalProgressValue,
                       accuracy: 0.01,
                       "Work timer progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertNil(sut.overtimeTimerService,
                       "Overtime timer service should be nil")
    }
    
    func test_resumeFromBackground_when_timerServiceWasNotStarted_noOvertime() {
        //Given
        let numberOfSecondsPassedInBackground = 10
        let expectedDisplayValue = TimeInterval(0)
        let expectedNormalProgressValue = CGFloat(0)
        var enterBackgroundDate: Date {
            Calendar.current.date(byAdding: .second, value: -numberOfSecondsPassedInBackground, to: Date())!
        }
        setUpWithOneTimer()
        //When
        sut.resumeFromBackground(enterBackgroundDate)
        //Then
        XCTAssertEqual(sut.workTimerService.counter,
                       expectedDisplayValue,
                       accuracy: 0.01,
                       "work timer counter value should be equal to \(numberOfSecondsPassedInBackground)")
        XCTAssertEqual(sut.workTimerService.progress,
                       expectedNormalProgressValue,
                       accuracy: 0.01,
                       "Work timer service progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertNil(sut.overtimeTimerService,
                       "Overtime progress should be nil")
    }
    
    func test_stopTimerService_stopsServiceAndEmitsDate_noOvertime() throws {
        //Given
        let numberOfFires = 10
        let expectation = XCTestExpectation(description: "Date emitted")
        setUpWithOneTimer()
        let datePublisher = sut.timerDidFinish
            .sink { _ in
                expectation.fulfill()
            }
        //When
        sut.startTimerService()
        fireTimer(numberOfFires)
        sut.stopTimerService()
        //Then
        wait(for: [expectation], timeout: 0.5)
        XCTAssertEqual(sut.state, .finished, "Service state should be finished")
    }
    
    func test_timerFinished_stopsServiceAndEmitsDate_noOvertime() throws {
        //Given
        let numberOfFires = workTimerLimit + 1
        let expectation = XCTestExpectation(description: "Date emitted")
        setUpWithOneTimer()
        let datePublisher = sut.timerDidFinish
            .sink { _ in
                expectation.fulfill()
            }
        //When
        sut.startTimerService()
        fireTimer(numberOfFires)
        //Then
        wait(for: [expectation], timeout: 0.5)
        XCTAssertEqual(sut.state, .finished, "Service state should be finished")
    }
     
    
    func test_startSecondTimer_whenFirstIsFinished_firstRun() {
        //Given
        let numberOfFires = workTimerLimit + 1
        let expectedNormalProgress = CGFloat(1)
        setUpWithTwoTimers()
        //When
        sut.startTimerService()
        fireTimer(numberOfFires)
        //Then
        XCTAssertEqual(sut.workTimerService.progress,
                       expectedNormalProgress,
                       "Normal progress should be equal to 0")
        XCTAssert(sut.overtimeTimerService?.progress ?? 0 > 0,
                  "Overtime progress should be bigger than 0")
        XCTAssertEqual(sut.state, .running, "SUT state should be running")
    }
    
    func test_startSecondTimer_whenFirstIsFinished_secondRun() {
        //Given
        let expectedState: TimerServiceState = .running
        let expectedProgress = CGFloat(0.2)
        let expectedDisplayValue = TimeInterval(integerLiteral: 20)
        setUpWithTwoTimers()
        //When
        sut.startTimerService()
        fireTimer(workTimerLimit + 10)
        sut.stopTimerService()
        sut.startTimerService()
        fireTimer(workTimerLimit + 20)
        //Then
        XCTAssertEqual(sut.state, expectedState, "State should be equal to \(expectedState)")
        XCTAssertEqual(sut.overtimeTimerService?.progress ?? 0, expectedProgress)
        XCTAssertEqual(sut.overtimeTimerService?.counter ?? 0, expectedDisplayValue)
    }
    
    func test_displayedValue_whenFirstTimerFinished_whenSecondTimerStarts() {
        //Given
        let expectedDisplayValueFromFirstTimer: CGFloat = 100
        let expectedDisplayValueFromSecondTimer: CGFloat = 1
        setUpWithTwoTimers()
        //When
        sut.startTimerService()
        fireTimer(workTimerLimit)
        //Then
        XCTAssertEqual(sut.workTimerService.counter, expectedDisplayValueFromFirstTimer)
        //When
        fireTimer(1)
        //Then
        XCTAssertEqual(sut.overtimeTimerService?.counter ?? 0, expectedDisplayValueFromSecondTimer)
    }
    
    func test_timerPropertiesUpdate_whenSecondTimerIsRunning() throws {
        //Given
        let numberOfFires = workTimerLimit + 10
        let expectedDisplayValue = TimeInterval(10)
        let expectedNormalProgressValue = CGFloat(1)
        let expectedOvertimeProgressValue = CGFloat(numberOfFires - workTimerLimit) / CGFloat(overtimeTimerLimit)
        setUpWithTwoTimers()
        //When
        sut.startTimerService()
        fireTimer(numberOfFires)
        //Then
        let overtimeService = try XCTUnwrap(sut.overtimeTimerService)
        XCTAssertEqual(overtimeService.counter, expectedDisplayValue, "Timer display value should be equal to 10")
        XCTAssertEqual(sut.workTimerService.progress, expectedNormalProgressValue, "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(overtimeService.progress, expectedOvertimeProgressValue, "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }
    
    func test_timerProperties_notUpdating_whenPaused_withOvertime() throws {
        //Given
        let numberOfFires = workTimerLimit + 10
        let expectedDisplayValue = TimeInterval(10)
        let expectedNormalProgressValue = CGFloat(1)
        let expectedOvertimeProgressValue = CGFloat(numberOfFires - workTimerLimit) / CGFloat(overtimeTimerLimit)
        setUpWithTwoTimers()
        //When
        sut.startTimerService()
        fireTimer(numberOfFires)
        sut.pauseTimerService()
        fireTimer(10)
        //Then
        let overtimeService = try XCTUnwrap(sut.overtimeTimerService)
        XCTAssertEqual(overtimeService.counter, expectedDisplayValue, "Timer display value should be equal to 10")
        XCTAssertEqual(sut.workTimerService.progress, expectedNormalProgressValue, "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(overtimeService.progress, expectedOvertimeProgressValue, "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }
    
    func test_resumeTimerService_whenPaused_withOvertime() throws {
        //Given
        let numberOfFires = workTimerLimit + 10
        let expectedDisplayValue = TimeInterval(20)
        let expectedNormalProgressValue = CGFloat(1)
        let expectedOvertimeProgressValue = CGFloat(20) / CGFloat(overtimeTimerLimit)
        setUpWithTwoTimers()
        //When
        sut.startTimerService()
        fireTimer(numberOfFires)
        sut.pauseTimerService()
        sut.resumeTimerService()
        fireTimer(10)
        //Then
        let overtimeService = try XCTUnwrap(sut.overtimeTimerService)
        XCTAssertEqual(overtimeService.counter,
                       expectedDisplayValue ,
                       "Timer display value should be equal to \(expectedDisplayValue)")
        XCTAssertEqual(sut.workTimerService.progress,
                       expectedNormalProgressValue,
                       "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(overtimeService.progress,
                       expectedOvertimeProgressValue,
                       "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }
    
    func test_resumeFromBackground_whenSecondTimerWasStarted() throws {
        //Given
        let numberOfSecondsPassedInBackground = 11
        let expectedDisplayValue = TimeInterval(numberOfSecondsPassedInBackground)
        let expectedNormalProgressValue = CGFloat(1)
        let expectedOvertimeProgressValue = CGFloat(numberOfSecondsPassedInBackground) / CGFloat(overtimeTimerLimit)
        var enterBackgroundDate: Date {
            Calendar.current.date(byAdding: .second, value: -numberOfSecondsPassedInBackground, to: Date())!
        }
        setUpWithTwoTimers()
        //When
        sut.startTimerService()
        fireTimer(workTimerLimit)
        sut.resumeFromBackground(enterBackgroundDate)
        //Then
        let overtimeService = try XCTUnwrap(sut.overtimeTimerService)
        XCTAssertEqual(overtimeService.counter,
                       expectedDisplayValue,
                       accuracy: 0.01,
                       "Timer display value should be equal to \(expectedDisplayValue)")
        XCTAssertEqual(sut.workTimerService.progress,
                       expectedNormalProgressValue,
                       "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(overtimeService.progress,
                       expectedOvertimeProgressValue,
                       accuracy: 0.01,
                       "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }
    
    func test_resumeFromBackground_whenTimeInBackgroundExceedsFirstTimeLimit() throws {
        //Given
        let numberOfSecondsPassedInBackground = workTimerLimit + 10
        let expectedDisplayValue = TimeInterval(numberOfSecondsPassedInBackground - workTimerLimit)
        let expectedNormalProgressValue = CGFloat(1)
        let expectedOvertimeProgressValue = CGFloat(numberOfSecondsPassedInBackground - workTimerLimit) / CGFloat(overtimeTimerLimit)
        var enterBackgroundDate: Date {
            Calendar.current.date(byAdding: .second, value: -numberOfSecondsPassedInBackground, to: Date())!
        }
        setUpWithTwoTimers()
        //When
        sut.startTimerService()
        
        sut.resumeFromBackground(enterBackgroundDate)
        //Then
        let overtimeService = try XCTUnwrap(sut.overtimeTimerService)
        XCTAssertEqual(overtimeService.counter,
                       expectedDisplayValue,
                       accuracy: 0.01,
                       "Timer display value should be equal to \(expectedDisplayValue)")
        XCTAssertEqual(sut.workTimerService.progress, expectedNormalProgressValue, "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(overtimeService.progress,
                       expectedOvertimeProgressValue,
                       accuracy: 0.01,
                       "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }
    
    func test_resumeFromBackground_whenTimeInBackgroundExceedsSumOfTimeLimits() throws {
        //Given
        let numberOfSecondsPassedInBackground = workTimerLimit + overtimeTimerLimit
        let expectedDisplayValue = TimeInterval(numberOfSecondsPassedInBackground - workTimerLimit)
        let expectedNormalProgressValue = CGFloat(1)
        let expectedOvertimeProgressValue = CGFloat(1)
        var enterBackgroundDate: Date {
            Calendar.current.date(byAdding: .second, value: -numberOfSecondsPassedInBackground - 20, to: Date())!
        }
        setUpWithTwoTimers()
        //When
        sut.startTimerService()
        
        sut.resumeFromBackground(enterBackgroundDate)
        //Then
        let overtimeService = try XCTUnwrap(sut.overtimeTimerService)
        XCTAssertEqual(overtimeService.counter, 
                       expectedDisplayValue, 
                       accuracy: 0.01,
                       "Timer display value should be equal to \(expectedDisplayValue)")
        XCTAssertEqual(sut.workTimerService.progress,
                       expectedNormalProgressValue,
                       "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(overtimeService.progress,
                       expectedOvertimeProgressValue, 
                       accuracy: 0.01,
                       "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }
    
    func test_stopTimerService_stopsSecondTimerAndSavesEntry() throws {
        let numberOfFires = workTimerLimit + overtimeTimerLimit
        let expectedDisplayValue = TimeInterval(overtimeTimerLimit)
        let expectedNormalProgressValue = CGFloat(1)
        let expectedOvertimeProgressValue = CGFloat(1)
        let expectation = XCTestExpectation(description: "Date emitted")
        setUpWithTwoTimers()
        let datePublisher = sut.timerDidFinish.sink { date in
            print("DatePublisher: \(date)")
            expectation.fulfill()
        }
        //When
        sut.startTimerService()
        fireTimer(numberOfFires)
        sut.stopTimerService()
        //Then
        wait(for: [expectation], timeout: 0.5)
        let overtimeService = try XCTUnwrap(sut.overtimeTimerService)
        XCTAssertEqual(overtimeService.counter,
                       expectedDisplayValue,
                       accuracy: 0.01,
                       "Timer display value should be equal to \(expectedDisplayValue)")
        XCTAssertEqual(sut.workTimerService.progress,
                       expectedNormalProgressValue,
                       "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(overtimeService.progress,
                       expectedOvertimeProgressValue,
                       accuracy: 0.01,
                       "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }
    
    func test_secondTimerFinished_stopsServiceAndSavesEntry() throws {
        //Given
        let expectation = XCTestExpectation(description: "Date emitted")
        let numberOfFires = workTimerLimit + overtimeTimerLimit + 1
        setUpWithTwoTimers()
        let datePublisher = sut.timerDidFinish.sink { _ in
            expectation.fulfill()
        }
        //When
        sut.startTimerService()
        fireTimer(numberOfFires)
        //Then
        wait(for: [expectation], timeout: 0.5)
        XCTAssertEqual(sut.state, .finished, "Service state should be finished")
    }
}

//MARK: HELPERS
extension TimerManagerTests {
    private func setUpWithOneTimer() {
        let configuration = TimerManagerConfiguration(workTimeInSeconds: TimeInterval(workTimerLimit),
                                                              isLoggingOvertime: false,
                                                              overtimeInSeconds: nil)
        sut = .init(timerProvider: MockTimer.self,
                    with: configuration)
        
    }
    
    private func setUpWithTwoTimers() {
        let configuration = TimerManagerConfiguration(workTimeInSeconds: TimeInterval(workTimerLimit),
                                                              isLoggingOvertime: true,
                                                              overtimeInSeconds: TimeInterval(overtimeTimerLimit))
        sut = TimerManager(timerProvider: MockTimer.self,
                           with: configuration)
    }
    
    private func fireTimer(_ numberOfFires: Int) {
        for _ in 0...numberOfFires - 1 {
            MockTimer.currentTimer.fire()
        }
    }
}


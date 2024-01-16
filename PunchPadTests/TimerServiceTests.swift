//
//  TimerServiceTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 22/12/2023.
//

import XCTest
@testable import PunchPad

final class TimerServiceTests: XCTestCase {
    let timerLimit = 180
    var sut: TimerService!
    
    override func setUp() {
        super.setUp()
        sut = .init(
            timerProvider: MockTimer.self,
            timerLimit: TimeInterval(timerLimit)
        )
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    private func fireTimer(_ numberOfFires: Int) {
        for _ in 0...numberOfFires - 1 {
            MockTimer.currentTimer.fire()
        }
    }
}

//MARK: TEST STATE CHANGES
extension TimerServiceTests {
    //INITIAL STATE
    func test_initialServiceState() {
        XCTAssertEqual(sut.serviceState, .notStarted, "Service should be not started")
    }
    
    //START EVENT SENT
    func test_startingTimer_whenServiceIsNotStarted() {
        sut.send(event: .start)
        XCTAssertEqual(sut.serviceState, .running, "Service should be running")
    }
    
    func test_startingTimer_whenServiceIsRunning() {
        sut.send(event: .start)
        sut.send(event: .start)
        XCTAssertEqual(sut.serviceState, .running, "Service should be running")
    }
    
    func test_startingTimer_whenServiceIsPaused() {
        sut.send(event: .start)
        sut.send(event: .pause)
        sut.send(event: .start)
        XCTAssertEqual(sut.serviceState, .running, "Service should be running")
    }
    
    func test_startingTimer_whenServiceIsFinished() {
        sut.send(event: .start)
        sut.send(event: .stop)
        sut.send(event: .start)
        XCTAssertEqual(sut.serviceState, .finished, "Service state should be finished")
    }

    //PAUSE EVENT SENT
    func test_pausingTimer_whenServiceIsNotStarted() {
        sut.send(event: .pause)
        XCTAssertEqual(sut.serviceState, .notStarted, "Service state should be not started ")
    }
    
    func test_pausingTimer_whenServiceIsRunning() {
        sut.send(event: .start)
        sut.send(event: .pause)
        XCTAssertEqual(sut.serviceState, .paused, "Service should be paused")
    }
    
    func test_pausingTimer_whenServiceIsFinished() {
        sut.send(event: .start)
        sut.send(event: .stop)
        sut.send(event: .pause)
        XCTAssertEqual(sut.serviceState, .finished, "Service should be finished")
    }
    
    func test_pausingTimer_whenServiceIsPaused() {
        sut.send(event: .start)
        sut.send(event: .pause)
        XCTAssertEqual(sut.serviceState, .paused, "Service should be paused")
    }

    //STOP EVENT SENT
    func test_stoppingTimer_whenServiceIsNotStarted() {
        sut.send(event: .stop)
        XCTAssertEqual(sut.serviceState, .notStarted, "Service state should be not started")
    }
    
    func test_stoppingTimer_whenServiceIsRunning() {
        sut.send(event: .start)
        sut.send(event: .stop)
        XCTAssertEqual(sut.serviceState, .finished, "Service state should be finished")
    }
    
    func test_stoppingTimer_whenServiceIsPaused() {
        sut.send(event: .start)
        sut.send(event: .pause)
        sut.send(event: .stop)
        XCTAssertEqual(sut.serviceState, .finished, "Service state should be finished")
    }
    
    func test_stoppingTimer_whenServiceIsFinished() {
        sut.send(event: .start)
        sut.send(event: .stop)
        sut.send(event: .stop)
        XCTAssertEqual(sut.serviceState, .finished, "Service state should be finished")
    }

    //RESUME EVENT SENT
    func test_resumeTimer_whenServiceIsNotStarted(){
        sut.send(event: .resumeWith(nil))
        XCTAssertEqual(sut.serviceState, .notStarted, "Service state should be not started")
    }
    
    func test_resumeTimer_whenServiceIsRunning(){
        sut.send(event: .start)
        sut.send(event: .resumeWith(nil))
        XCTAssertEqual(sut.serviceState, .running, "Service state should be running")
    }
    
    func test_resumeTimer_whenServiceIsPaused(){
        sut.send(event: .start)
        sut.send(event: .pause)
        sut.send(event: .resumeWith(nil))
        XCTAssertEqual(sut.serviceState, .running, "Service state should be running")
    }
    
    func test_resumeTimer_whenServiceIsFinished(){
        sut.send(event: .start)
        sut.send(event: .stop)
        sut.send(event: .resumeWith(nil))
        XCTAssertEqual(sut.serviceState, .finished, "Service state should be finished")
    }
}

extension TimerServiceTests {
    func testUpdateTimerCounter() {
        // Given
        let numberOfFires = 10
        let expectedCounterValue: TimeInterval = TimeInterval(numberOfFires)
        //When
        sut.send(event: .start)
        fireTimer(numberOfFires)
        //Then
        XCTAssertEqual(sut.counter, expectedCounterValue, "Counter value should be equal to predicted value")
    }
    
    func testUpdateProgress() {
        // Given
        let numberOfFires: Int = timerLimit / 4
        let expectedProgressValue: CGFloat = 0.25
        //When
        sut.send(event: .start)
        fireTimer(numberOfFires)
        //Then
        XCTAssertEqual(sut.progress, expectedProgressValue, "Progress value should be equal to predicted value (\(expectedProgressValue))")
    }
    
    func test_counter_notUpdating_whenPaused() {
        //Given
        let numberOfFires: Int = timerLimit / 4
        //When
        sut.send(event: .start)
        sut.send(event: .pause)
        fireTimer(numberOfFires)
        //Then
        XCTAssertEqual(sut.counter, 0, "Counter value should be 0")
        XCTAssertEqual(sut.progress, 0, "Progress value should be 0")
    }
    
    func test_counterAndProgress_updated_whenResumeWithValueSent() {
        //Given
        let numberOfFires: Int = timerLimit / 4
        //When
        sut.send(event: .start)
        sut.send(event: .pause)
        sut.send(event: .resumeWith(TimeInterval(numberOfFires)))
        XCTAssertEqual(sut.counter, TimeInterval(timerLimit / 4), "Counter value should be \(timerLimit/4)")
        XCTAssertEqual(sut.progress, 0.25, "Progress value should be 0.25")
    }
}

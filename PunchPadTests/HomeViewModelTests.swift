//
//  TimerModelTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/12/23.
//

import XCTest
@testable import PunchPad

final class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var testContainer: TestContainer!

    var workTimerLimit: Int = 100
    var overtimeTimerLimit: Int = 100
    
    override func setUp() {
        super.setUp()
        SettingsStore.setTestUserDefaults()
        testContainer = TestContainer()
        testContainer.dataManager.deleteAll()
        sut = .init(HomeViewModel(dataManager: testContainer.dataManager,
                                  settingsStore: testContainer.settingsStore,
                                  payManager: PayManager(dataManager: testContainer.dataManager,
                                                         settingsStore: testContainer.settingsStore,
                                                         calendar: .current),
                                  notificationService: NotificationService(center: .current()),
                                  timerProvider: MockTimer.self)
        )
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}

//MARK: TIMER STATE CHANGE FUNCTIONS
extension HomeViewModelTests {
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
        XCTAssertEqual(sut.normalProgress, expectedProgress)
        XCTAssertEqual(sut.timerDisplayValue, expectedDisplayValue)
    }
    
    func test_timerProperties_updateWhenRunning_noOvertime() {
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
    
    func test_timerProperties_notUpdating_whenPaused_noOvertime() {
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
    
    func test_resumeTimerService_whenPaused_noOvertime() {
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
    
    func test_stopTimerService_stopsServiceAndSavesEntry_noOvertime() throws {
        //Given
        let numberOfExistingEntries = try numberOfEntries()
        let numberOfFires = 10
        setUpWithOneTimer()
        //When
        sut.startTimerService()
        fireTimer(numberOfFires)
        sut.stopTimerService()
        //Then
        XCTAssertEqual(sut.state, .finished, "Service state should be finished")
        XCTAssertEqual(try numberOfEntries(), numberOfExistingEntries + 1, "Additional entry should be saved")
    }
    
    func test_timerFinished_stopsServiceAndSavesEntry_noOvertime() throws {
        //Given
        let expectedNumberOfEntries = try numberOfEntries() + 1
        let numberOfFires = workTimerLimit + 1
        setUpWithOneTimer()
        //When
        sut.startTimerService()
        fireTimer(numberOfFires)
        //Then
        XCTAssertEqual(sut.state, .finished, "Service state should be finished")
        XCTAssertEqual(try numberOfEntries(), expectedNumberOfEntries, "Additional entry should be saved")
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
        XCTAssertEqual(sut.normalProgress, expectedNormalProgress, "Normal progress should be equal to 0")
        XCTAssert(sut.overtimeProgress > 0, "Overtime progress should be bigger than 0")
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
        XCTAssertEqual(sut.overtimeProgress, expectedProgress)
        XCTAssertEqual(sut.timerDisplayValue, expectedDisplayValue)
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
        XCTAssertEqual(sut.timerDisplayValue, expectedDisplayValueFromFirstTimer)
        //When
        fireTimer(1)
        //Then
        XCTAssertEqual(sut.timerDisplayValue, expectedDisplayValueFromSecondTimer)
    }
    
    func test_timerPropertiesUpdate_whenSecondTimerIsRunning() {
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
        XCTAssertEqual(sut.timerDisplayValue, expectedDisplayValue, "Timer display value should be equal to 10")
        XCTAssertEqual(sut.normalProgress, expectedNormalProgressValue, "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(sut.overtimeProgress, expectedOvertimeProgressValue, "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }
    
    func test_timerProperties_notUpdating_whenPaused_withOvertime() {
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
        XCTAssertEqual(sut.timerDisplayValue, expectedDisplayValue, "Timer display value should be equal to 10")
        XCTAssertEqual(sut.normalProgress, expectedNormalProgressValue, "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(sut.overtimeProgress, expectedOvertimeProgressValue, "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }
    
    func test_resumeTimerService_whenPaused_withOvertime() {
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
        XCTAssertEqual(sut.timerDisplayValue, expectedDisplayValue , "Timer display value should be equal to \(expectedDisplayValue)")
        XCTAssertEqual(sut.normalProgress, expectedNormalProgressValue, "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(sut.overtimeProgress, expectedOvertimeProgressValue, "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }
    
    func test_stopTimerService_stopsSecondTimerAndSavesEntry() throws {
        let numberOfFires = workTimerLimit + overtimeTimerLimit
        let expectedDisplayValue = TimeInterval(overtimeTimerLimit)
        let expectedNormalProgressValue = CGFloat(1)
        let expectedOvertimeProgressValue = CGFloat(1)
        let expectedNumberOfEntries = try numberOfEntries()/*DataManager.testing.entryArray.count*/ + 1
        setUpWithTwoTimers()
        //When
        sut.startTimerService()
        fireTimer(numberOfFires)
        sut.stopTimerService()
        //Then
        XCTAssertEqual(try numberOfEntries(), expectedNumberOfEntries, "Number of entries should be equal to \(expectedNumberOfEntries)")
        XCTAssertEqual(sut.timerDisplayValue, expectedDisplayValue, accuracy: 0.01, "Timer display value should be equal to \(expectedDisplayValue)")
        XCTAssertEqual(sut.normalProgress, expectedNormalProgressValue, "Normal progress should be equal to \(expectedNormalProgressValue)")
        XCTAssertEqual(sut.overtimeProgress, expectedOvertimeProgressValue, accuracy: 0.01, "Overtime progress should be equal to \(expectedOvertimeProgressValue)")
    }
    
    func test_secondTimerFinished_stopsServiceAndSavesEntry() throws {
        //Given
        let expectedNumberOfEntries = try numberOfEntries() + 1
        let numberOfFires = workTimerLimit + overtimeTimerLimit + 1
        setUpWithTwoTimers()
        //When
        sut.startTimerService()
        fireTimer(numberOfFires)
        //Then
        XCTAssertEqual(sut.state, .finished, "Service state should be finished")
        XCTAssertEqual(try numberOfEntries(), expectedNumberOfEntries, "Additional entry should be saved")
    }
}

//MARK: BACKGROUND AND FOREGROUND TIMER UPDATES
extension HomeViewModelTests {
    func test_resumeFromBackground_withOneTimer_notExceedingTimerLimit() {
        //Given
        setUpWithOneTimer()
        sut.startTimerService()
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        sleep(5)
        //When
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        //Then
        XCTAssertEqual(sut.normalProgress, 0.05, accuracy: 0.01)
    }
    
    func test_resumeFromBackground_withOneTimer_exceedingTimerLimit() {
        //Given
        workTimerLimit = 2
        setUpWithOneTimer()
        sut.startTimerService()
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        sleep(3)
        //When
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        //Then
        XCTAssertEqual(sut.normalProgress, 1, accuracy: 0.01)
    }
    
    func test_resumeFromBackground_withOneTimer_exceedingTimerLimit_savesEntry() throws {
        //Given
        let expectedEntriesCount = try numberOfEntries() + 1
        workTimerLimit = 2
        setUpWithOneTimer()
        let expectedStartTime = Date().timeIntervalSince1970
        let expectedFinishTimer = expectedStartTime + 2
        sut.startTimerService()
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        sleep(5)
        //When
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        //Then
        XCTAssertEqual(expectedEntriesCount, try numberOfEntries(), "There should be additional entry in array")
        guard let addedEntry = testContainer.dataManager.fetchOldestExisting() else {
            XCTFail("Failed to retrieve expected entry in \(#function)")
            return
        }
        XCTAssertEqual(addedEntry.startDate.timeIntervalSince1970, expectedStartTime, accuracy: 0.01)
        XCTAssertEqual(addedEntry.finishDate.timeIntervalSince1970, expectedFinishTimer, accuracy: 0.01)
    }
    
    func test_resumeFromBackground_withTwoTimers_notExceedingFirstTimerLimit() throws {
        //Given
        workTimerLimit = 10
        setUpWithTwoTimers()
        sut.startTimerService()
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        sleep(3)
        //When
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        //Then
        XCTAssertEqual(sut.normalProgress, 0.3, accuracy: 0.01)
        XCTAssertEqual(sut.overtimeProgress, 0, accuracy: 0.01)
        XCTAssertEqual(try numberOfEntries(), 0)
    }
    
    func test_resumeFromBackground_withTwoTimers_exceedingFirstTimerLimit() {
        //Given
        workTimerLimit = 2
        setUpWithTwoTimers()
        sut.startTimerService()
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        sleep(3)
        //When
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        //Then
        XCTAssertEqual(sut.normalProgress, 1, accuracy: 0.01)
        XCTAssertEqual(sut.overtimeProgress, 0.01, accuracy: 0.01)
    }
    
    func test_resumeFromBackground_withTwoTimers_exceedingSecondTimer() throws {
        //Given
        workTimerLimit = 2
        overtimeTimerLimit = 2
        setUpWithTwoTimers()
        let expectedStartTimeInterval = Date().timeIntervalSince1970
        let expectedFinishTimeInterval = expectedStartTimeInterval + 4
        let expectedEntriesCount = try numberOfEntries() + 1
        sut.startTimerService()
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        sleep(5)
        //When
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        //Then
        XCTAssertEqual(sut.normalProgress, 1, accuracy: 0.01)
        XCTAssertEqual(sut.overtimeProgress, 1, accuracy: 0.01)
        XCTAssertEqual(expectedEntriesCount, try numberOfEntries(), "There should be additional entry in array")
        guard let addedEntry = testContainer.dataManager.fetchOldestExisting() else {
            XCTFail("Failed to retrieve expected entry in \(#function)")
            return
        }
        XCTAssertEqual(addedEntry.startDate.timeIntervalSince1970, expectedStartTimeInterval, accuracy: 0.01)
        XCTAssertEqual(addedEntry.finishDate.timeIntervalSince1970, expectedFinishTimeInterval, accuracy: 0.01)
        XCTAssertEqual(addedEntry.workTimeInSeconds, 2)
        XCTAssertEqual(addedEntry.overTimeInSeconds, 2)
    }
    
    func test_resumeFromBackground_whenEnteredDuringSecondTimer_withTwoTimers_exceedingSecondTimer() throws {
        //Given
        workTimerLimit = 2
        overtimeTimerLimit = 2
        setUpWithTwoTimers()
        let expectedStartTimeInterval = Date().timeIntervalSince1970
        let expectedFinishTimeInterval = expectedStartTimeInterval + 4
        let expectedEntriesCount = try numberOfEntries() + 1
        sut.startTimerService()
        fireTimer(3)
        sleep(3)
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        sleep(2)
        //When
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        //Then
        XCTAssertEqual(sut.normalProgress, 1, accuracy: 0.01)
        XCTAssertEqual(sut.overtimeProgress, 1, accuracy: 0.01)
        XCTAssertEqual(expectedEntriesCount, try numberOfEntries(), "There should be additional entry in array")
        guard let addedEntry = testContainer.dataManager.fetchOldestExisting() else {
            XCTFail("Failed to retrieve expected entry in \(#function)")
            return
        }
        XCTAssertEqual(addedEntry.startDate.timeIntervalSince1970, expectedStartTimeInterval, accuracy: 1)
        XCTAssertEqual(addedEntry.finishDate.timeIntervalSince1970, expectedFinishTimeInterval, accuracy: 1)
        XCTAssertEqual(addedEntry.workTimeInSeconds, 2)
        XCTAssertEqual(addedEntry.overTimeInSeconds, 2)
    }
}

//MARK: HELPERS
extension HomeViewModelTests {
    private func setUpWithOneTimer() {
        testContainer.settingsStore.isLoggingOvertime = false
        testContainer.settingsStore.workTimeInSeconds = workTimerLimit
        sut = .init(HomeViewModel(dataManager: testContainer.dataManager,
                                  settingsStore: testContainer.settingsStore,
                                  payManager: PayManager(dataManager: testContainer.dataManager,
                                                         settingsStore: testContainer.settingsStore,
                                                         calendar: .current),
                                  notificationService: NotificationService(center: .current()),
                                  timerProvider: MockTimer.self)
        )
    }
    
    private func setUpWithTwoTimers() {
        testContainer.settingsStore.isLoggingOvertime = true
        testContainer.settingsStore.workTimeInSeconds = workTimerLimit
        testContainer.settingsStore.maximumOvertimeAllowedInSeconds = overtimeTimerLimit
        sut = .init(dataManager: testContainer.dataManager,
                    settingsStore: testContainer.settingsStore,
                    payManager: PayManager(dataManager: testContainer.dataManager,
                                           settingsStore: testContainer.settingsStore,
                                           calendar: .current),
                    notificationService: NotificationService(center: .current()),
                    timerProvider: MockTimer.self)
    }
    
    private func fireTimer(_ numberOfFires: Int) {
        for _ in 0...numberOfFires - 1 {
            MockTimer.currentTimer.fire()
        }
    }
    
    private func numberOfEntries() throws -> Int {
        guard let manager = testContainer.dataManager as? TestDataManager else { throw TestError.failedToCast }
        return try manager.numberOfEntries()
    }
    
    enum TestError: Error {
        case failedToCast
    }
}


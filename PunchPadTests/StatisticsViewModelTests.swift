//
//  StatisticsViewModelTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/21/23.
//

import XCTest
import CoreData
import Combine
import UIComponents

@testable import PunchPad

final class StatisticsViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private let calendar = Calendar.current
    var sut: StatisticsViewModel!
    var container: TestContainer!
    override func setUp() {
        container = TestContainer()
        sut = StatisticsViewModel(dataManager: container.dataManager,
                                  payManager: container.payManager,
                                  settingsStore: container.settingsStore,
                                  calendar: .current
        )
    }
    
    override func tearDown() {
        sut = nil
        container.dataManager.deleteAll()
        container = nil
    }
    
    func test_initialState_withNoData() {
        XCTAssert(sut.chartTimeRange == .week)
        XCTAssert(sut.periodDisplayed.0 < Date() && Date() < sut.periodDisplayed.1)
        XCTAssert(sut.entryInPeriod.isEmpty)
        XCTAssert(sut.entrySummaryByMonthYear.isEmpty)
        XCTAssertNil(sut.entrySummaryByWeekYear)
        XCTAssert(sut.workedHoursInPeriod == 0)
        XCTAssert(sut.overtimeHoursInPeriod == 0)
    }
    
    func test_entryInPeriod_updates_whenDataSaved() {
        //Given
        let expectation = XCTestExpectation(description: "Published change in entry array")
        sut.$entryInPeriod
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        //When
        addTestDataForCurrentMonth()
        //Then
        let result = XCTWaiter.wait(for: [expectation], timeout: 0.5)
        XCTAssertEqual(result, .completed)
    }
    
    func test_entryInPeriod_updates_whenLoadingNextPeriod() throws {
        //Given
        let entriesPublisher = sut.$entryInPeriod
            .collectNext(2)
        addTestDataForCurrentMonth()
        //When
        sut.loadNextPeriod()
        //Then
        let entryArrays = try awaitPublisher(entriesPublisher)
        XCTAssertEqual(entryArrays.count, 2)
        guard let oldPeriodFirstEntryStartDate = entryArrays.first?.first?.startDate,
              let newPeriodFirstEntryFinishDate = entryArrays.last?.first?.finishDate else {
            XCTFail("Failed to retrieve published data in \(#file), line: \(#line)")
            return
        }
        XCTAssertEqual(calendar.dateComponents([.day], from: oldPeriodFirstEntryStartDate, to: newPeriodFirstEntryFinishDate).day ?? 0, 6)
    }
    
    func test_entryInPeriod_updates_whenLoadingPreviousPeriod() throws {
        //Given
        let entriesPublisher = sut.$entryInPeriod
            .collectNext(2)
        addTestDataForCurrentMonth()
        //When
        sut.loadPreviousPeriod()
        //Then
        let entryArrays = try awaitPublisher(entriesPublisher)
        XCTAssertEqual(entryArrays.count, 2)
        guard let oldPeriodFirstEntryFinishDate = entryArrays.first?.first?.finishDate,
              let newPeriodFirstEntryStartDate = entryArrays.last?.first?.startDate else {
            XCTFail("Failed to retrieve published data in \(#file), line: \(#line)")
            return
        }
        XCTAssertEqual(calendar.dateComponents([.day], from: newPeriodFirstEntryStartDate, to: oldPeriodFirstEntryFinishDate).day ?? 0, 7)
    }
    
    func test_entryInPeriod_updated_whenUpdatingChartTimeRangeToMonth() throws {
        //Given
        guard let expectedNumberOfEntries = calendar.range(of: .day, in: .month, for: Date())?.count else {
            XCTFail("Failed to construct expected result in \(#file), line: \(#line)")
            return
        }
        let entriesPublisher = sut.$entryInPeriod
            .collectNext(2)
        addTestDataForCurrentYear()
        //When
        sut.chartTimeRange = .month
        //Then
        let resultArrays = try awaitPublisher(entriesPublisher)
        XCTAssertEqual(resultArrays.last?.count, expectedNumberOfEntries + 1)
    }
    
    func test_entryInPeriod_summaryByMonthYear_updated_whenUpdatingChartTimeRangeToYear() throws {
        //Given
        guard let expectedNumberOfEntries = calendar.range(of: .day, in: .year, for: Date())?.count else {
            XCTFail("Failed to construct expected result in \(#file), line: \(#line)")
            return
        }
        let entriesPublisher = sut.$entryInPeriod
            .collectNext(2)
        addTestDataForCurrentYear()
        //When
        sut.chartTimeRange = .year
        //Then
        let result = try awaitPublisher(entriesPublisher)
        XCTAssertEqual(result.last?.count, expectedNumberOfEntries)
        XCTAssertEqual(sut.entrySummaryByMonthYear.count, 12)
        XCTAssertNil(sut.entrySummaryByWeekYear)
    }
    
    func test_entryInPeriod_udapted_whenUpdatingChartTimeRangeToAll_withYearOfEntries() throws {
        //Given
        guard let expectedNumberOfEntries = calendar.range(of: .day, in: .year, for: Date())?.count else {
            XCTFail("Failed to construct expected result in \(#file), line: \(#line)")
            return
        }
        let entriesPublisher = sut.$entryInPeriod
            .collectNext(2)
        addTestDataForCurrentYear()
        //When
        sut.chartTimeRange = .all
        //Then
        let result = try awaitPublisher(entriesPublisher)
        XCTAssertEqual(result.last?.count, expectedNumberOfEntries)
        XCTAssertEqual(sut.entrySummaryByMonthYear.count, 12)
        XCTAssertNil(sut.entrySummaryByWeekYear)
    }
    
    func test_entryInPeriod_updated_whenUpdatingChartTimeRangeToAll_withMonthOfEntries() throws {
        //Given
        guard let expectedNumberOfEntries = calendar.range(of: .day, in: .month, for: Date())?.count,
        let expectedNumberOfWeeks = calendar.range(of: .weekOfMonth, in: .month, for: Date())?.count else {
            XCTFail("Failed to construct expected result in \(#file), line: \(#line)")
            return
        }
        let entriesPublisher = sut.$entryInPeriod
            .collectNext(2)
        addTestDataForCurrentMonth()
        //When
        sut.chartTimeRange = .all
        //Then
        let result = try awaitPublisher(entriesPublisher)
        XCTAssertEqual(result.last?.count, expectedNumberOfEntries)
        XCTAssertEqual(sut.entrySummaryByMonthYear.count, 1)
        let unwrappedSummaryByWeekYear = try XCTUnwrap(sut.entrySummaryByWeekYear)
        XCTAssertEqual(unwrappedSummaryByWeekYear.count, expectedNumberOfWeeks)
    }
}

extension StatisticsViewModelTests {
    private func addTestDataForCurrentMonth() {
        let testEntries = PreviewDataFactory.buildDataForPreviewForMonth(containing: Date(), using: .current)
        for entry in testEntries {
            container.dataManager.updateAndSave(entry: entry)
        }
    }
    
    private func addTestDataForCurrentYear() {
        let testEntries = PreviewDataFactory.buildDataForPreviewForYear(containing: Date(), using: .current)
        for entry in testEntries {
            container.dataManager.updateAndSave(entry: entry)
        }
    }
}

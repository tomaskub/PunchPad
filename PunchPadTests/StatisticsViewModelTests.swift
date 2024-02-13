//
//  StatisticsViewModelTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/21/23.
//

import XCTest
import CoreData
import Combine

@testable import PunchPad

final class StatisticsViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private let calendar = Calendar.current
    var sut: StatisticsViewModel!
    var container: Container!
    override func setUp() {
        container = Container()
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
        XCTAssertNil(sut.entriesSummaryByWeekYear)
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
        wait(for: [expectation])
        XCTAssertEqual(sut.entryInPeriod.filter({ $0.workTimeInSeconds == 0 }).count, 2, "There should be 2 entries with 0 work time (placeholder entries for weekend)")
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
        XCTAssertEqual(calendar.dateComponents([.day], from: oldPeriodFirstEntryStartDate, to: newPeriodFirstEntryFinishDate).day ?? 0, 7)
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
        XCTAssertEqual(resultArrays.last?.count, expectedNumberOfEntries)
    }
    
    func test_entryInPeriod_updated_whenUpdatingChartTimeRangeToYear() throws {
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
        let groupedEntries = sut.entrySummaryByMonthYear
        XCTAssertEqual(groupedEntries.count, 12)
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

extension StatisticsViewModelTests {
    func test_createSummaryForAll_with29Entries() throws {
        let entriesPublisher = sut.$entryInPeriod
            .dropFirst()
            .collect(2)
            .first()
        
        let testEntries = PreviewDataFactory.buildDataForPreviewForMonth(containing: Date(), using: .current)
        for entry in testEntries {
            container.dataManager.updateAndSave(entry: entry)
        }
        sut.loadNextPeriod()
        let entryArrays = try awaitPublisher(entriesPublisher)
        XCTAssertEqual(entryArrays.count, 2)
        //        sut.chartTimeRange = .all
        //        XCTAssertEqual(sut.entriesSummaryByWeekYear?.count, 5)
    }
    func testEntriesForChart() {
        
        let dataManager = DataManager.testing
        
        dataManager.updateAndSave(entry: Entry(
            startDate: Calendar.current.date(byAdding: .hour, value: -8, to: Date())!,
            finishDate: Date(),
            workTimeInSec: 8 * 3600,
            overTimeInSec: 0,
            maximumOvertimeAllowedInSeconds: 5*3600,
            standardWorktimeInSeconds: 8*3600,
            grossPayPerMonth: 10000,
            calculatedNetPay: nil)
        )
        let correctValue: Int = {
            let components = Calendar.current.dateComponents([.month, .year], from: Date())
            let startOfTheMonth = Calendar.current.date(from: components)!
            return Calendar.current.range(of: .day, in: .month, for: startOfTheMonth)!.count
        }()
        sut.chartTimeRange = .month
        let result = sut.entryInPeriod
        XCTAssert(result.count == correctValue, "There should be objects in the array")
    }
    
    //    func test_createPlaceholderEntries() {
    //        guard let inputStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 13)),
    //              let inputFinishDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 20)),
    //              let expectedLastEntryDate = Calendar.current.date(byAdding: .day, value: -1, to: inputFinishDate) else {
    //                XCTFail("Failed to generate input and predicted output dates")
    //                return
    //            }
    //        let inputPeriod = (inputStartDate, inputFinishDate)
    //        let result = sut.createPlaceholderEntries(for: inputPeriod)
    //        XCTAssertTrue(result[0].startDate == inputStartDate, "Results should start with entry with input start date")
    //        XCTAssertTrue(result.last?.startDate == expectedLastEntryDate, "Results should end with entry with input finish date")
    //    }
    
    
    
    func test_createSummaryForAll_with365Entries() {
        let testEntries = PreviewDataFactory.buildDataForPreviewForYear(containing: Date(), using: .current)
        for entry in testEntries {
            container.dataManager.updateAndSave(entry: entry)
        }
        sut.chartTimeRange = .all
        XCTAssertNil(sut.entrySummaryByMonthYear)
        XCTAssertEqual(sut.entrySummaryByMonthYear.count, 12)
    }
}

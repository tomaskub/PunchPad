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
    
    func test_entryInPeriod_updates() {
        let expectation = XCTestExpectation(description: "Published change in entry array")
        sut.$entryInPeriod
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        addTestDataForCurrentMonth()
        
        wait(for: [expectation])
        XCTAssertEqual(sut.entryInPeriod.filter({ $0.workTimeInSeconds == 0 }).count, 2, "There should be 2 entries with 0 work time (placeholder entries)")
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

//
//  StatisticsViewModelTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/21/23.
//

import XCTest
import CoreData
@testable import PunchPad

final class StatisticsViewModelTests: XCTestCase {

    var sut: StatisticsViewModel!
    var container: Container!
    override func setUp() {
        container = Container()
        sut = StatisticsViewModel(dataManager: container.dataManager,
                                  payManager: container.payManager,
                                  settingsStore: container.settingsStore)
    }

    override func tearDown() {
        sut = nil
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
        let result = sut.entriesForChart
        XCTAssert(result.count == correctValue, "There should be objects in the array")
    }
    
    func test_createPlaceholderEntries() {
        guard let inputStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 13)),
              let inputFinishDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 20)),
              let expectedLastEntryDate = Calendar.current.date(byAdding: .day, value: -1, to: inputFinishDate) else {
                XCTFail("Failed to generate input and predicted output dates")
                return
            }
        let inputPeriod = (inputStartDate, inputFinishDate)
        let result = sut.createPlaceholderEntries(for: inputPeriod)
        XCTAssertTrue(result[0].startDate == inputStartDate, "Results should start with entry with input start date")
        XCTAssertTrue(result.last?.startDate == expectedLastEntryDate, "Results should end with entry with input finish date")
    }
}

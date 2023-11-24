//
//  StatisticsViewModelTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/21/23.
//

import XCTest
import CoreData
@testable import ClockIn

final class StatisticsViewModelTests: XCTestCase {

    var sut: StatisticsViewModel!
    var container: Container!
    override func setUp() {
        container = Container()
        let settingsStore = SettingsStore()
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
            overTimeInSec: 0))
        let correctValue: Int = {
            let components = Calendar.current.dateComponents([.month, .year], from: Date())
            let startOfTheMonth = Calendar.current.date(from: components)!
            return Calendar.current.range(of: .day, in: .month, for: startOfTheMonth)!.count
        }()
        
        let result = sut.entriesForChart
        XCTAssert(result.count == correctValue, "There should be 7 objects in the array")
    }
    
    func test_generatePeriod_forMonth() {
        let inputDate = {
            let dateComponents = DateComponents(year: 2023, month: 11, day: 20)
            return Calendar.current.date(from: dateComponents)
        }()
        let startDate = {
            let dateComponents = DateComponents(year: 2023, month: 11, day: 1)
            return Calendar.current.date(from: dateComponents)
        }()
        let finishDate = {
            let dateComponents = DateComponents(year: 2023, month: 11, day: 30)
            return Calendar.current.date(from: dateComponents)
        }()
        guard let inputDate, let startDate, let finishDate else {
            XCTFail("Failed to generate input and predicted output dates")
            return
        }
        let expectedResult = (startDate, finishDate)
        let result = sut.generatePeriod(for: inputDate, in: .month)
        
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssert(result.1 == expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_generatePeriod_forWeek() {
        let inputDate = {
            let dateComponents = DateComponents(year: 2023, month: 11, day: 22)
            return Calendar.current.date(from: dateComponents)
        }()
        let startDate = {
            let dateComponents = DateComponents(year: 2023, month: 11, day: 20)
            return Calendar.current.date(from: dateComponents)
        }()
        let finishDate = {
            let dateComponents = DateComponents(year: 2023, month: 11, day: 26)
            return Calendar.current.date(from: dateComponents)
        }()
        guard let inputDate, let startDate, let finishDate else {
            XCTFail("Failed to generate input and predicted output dates")
            return
        }
        
        let result = sut.generatePeriod(for: inputDate, in: .week)
        let expectedResult = (startDate, finishDate)
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssert(result.1 == expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_generatePeriod_forYear() {
        let inputDate = {
            let dateComponents = DateComponents(year: 2023, month: 11, day: 20)
            return Calendar.current.date(from: dateComponents)
        }()
        let startDate = {
            let dateComponents = DateComponents(year: 2023, month: 1, day: 1)
            return Calendar.current.date(from: dateComponents)
        }()
        let finishDate = {
            let dateComponents = DateComponents(year: 2023, month: 12, day: 31)
            return Calendar.current.date(from: dateComponents)
        }()
        guard let inputDate, let startDate, let finishDate else {
            XCTFail("Failed to generate input and predicted output dates")
            return
        }
        
        let result = sut.generatePeriod(for: inputDate, in: .year)
        let expectedResult = (startDate, finishDate)
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssert(result.1 == expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
}

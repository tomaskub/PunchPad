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
    
    override func setUp() {
        let settingsStore = SettingsStore()
        sut = StatisticsViewModel(dataManager: DataManager.testing,
                                  payManager: PayManager(dataManager: DataManager.testing, settingsStore: settingsStore),
                                  settingsStore: settingsStore)
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
    
    //TODO: FIX MISMATCH BETWEEN DATES FROM DATE FORMATTER AND CURRENT CALENDAR
    func test_generatePeriod_forMonth() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let inputDate = dateFormatter.date(from: "20/11/2023")
        let startDate = dateFormatter.date(from: "01/11/2023")
        let finishDate = dateFormatter.date(from: "30/11/2023")
        
        guard let inputDate, let startDate, let finishDate else {
            XCTFail("Failed to generate input and predicted output dates")
            return
        }
        
        let result = sut.generatePeriod(for: inputDate, in: .month)
        let expectedResult = (Calendar.current.startOfDay(for: startDate), Calendar.current.startOfDay(for: finishDate))
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssert(result.1 == expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_generatePeriod_forWeek() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let inputDate = dateFormatter.date(from: "22/11/2023")
        let startDate = dateFormatter.date(from: "20/11/2023")
        let finishDate = dateFormatter.date(from: "26/11/2023")
        
        guard let inputDate, let startDate, let finishDate else {
            XCTFail("Failed to generate input and predicted output dates")
            return
        }
        
        let result = sut.generatePeriod(for: inputDate, in: .week)
        let expectedResult = (Calendar.current.startOfDay(for: startDate), Calendar.current.startOfDay(for: finishDate))
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssert(result.1 == expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_generatePeriod_forYear() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let inputDate = dateFormatter.date(from: "20/11/2023")
        let startDate = dateFormatter.date(from: "01/01/2023")
        let finishDate = dateFormatter.date(from: "31/12/2023")
        
        guard let inputDate, let startDate, let finishDate else {
            XCTFail("Failed to generate input and predicted output dates")
            return
        }
        
        let result = sut.generatePeriod(for: inputDate, in: .year)
        let expectedResult = (Calendar.current.startOfDay(for: startDate), Calendar.current.startOfDay(for: finishDate))
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssert(result.1 == expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
}

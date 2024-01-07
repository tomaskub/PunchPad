//
//  PayManagerTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import XCTest
import CoreData
@testable import ClockIn

final class PayManagerTests: XCTestCase {
    var sut: PayManager!
    var settingsStore: SettingsStore!
    var dataManager: DataManager!
    var periodService: ChartPeriodService!
    
    override func setUp() {
        super.setUp()
        dataManager = DataManager.testing
        dataManager.deleteAll()
        SettingsStore.setTestUserDefaults()
        settingsStore = SettingsStore()
        sut = .init(dataManager: dataManager,
                    settingsStore: settingsStore)
        periodService = ChartPeriodService(calendar: .current)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        settingsStore = nil
        dataManager = nil
    }
    
    func testGeneratingDataForPastPeriod() {
        //Given
        guard let date = generateStableDate(),
        let testPeriod = try? periodService.generatePeriod(for: date, in: .month) else {
            XCTFail("Failed to build date from given string")
            return
        }
        let numberOfWorkingDays = addTestData(forPeriod: testPeriod,
                                              workTimeInSec: 8 * 3600,
                                              overtimeInSec: 0,
                                              standardWorkTimeInSec: 8 * 3600,
                                              maximumOvertimeInSec: 5 * 3600,
                                              grossPayPerMonth: settingsStore.grossPayPerMonth
        )
        //When
        sut.updatePeriod(with: testPeriod)
        //Then
        let result = sut.grossDataForPeriod
        let expectedPayHour = Double(settingsStore.grossPayPerMonth) / Double(numberOfWorkingDays * 8)
        XCTAssertEqual(result.numberOfWorkingDays, numberOfWorkingDays)
        XCTAssertEqual(result.payPerHour, expectedPayHour)
        XCTAssertNil(result.payPredicted)
        XCTAssertEqual(result.payUpToDate, Double(settingsStore.grossPayPerMonth))
    }
}


extension PayManagerTests {
    /// Returns a date object representing start of day of April 16, 2023
    func generateStableDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let dateString = "April 16, 2023"
        return formatter.date(from: dateString)
    }
    /// Add test data for a given period, using entries constructed from input parameters. Entries are saved in testing data manager instance.
    /// - Parameters:
    ///     - period: period in which to create test data
    ///     - workTimeInSec: time worked in entry
    ///     - overtimeInSec: overtime in entry
    ///     - standardWorkTimeInSec: standard work time for entry
    ///     - maximumOvertimeInSec: maximum amount of overtime for entry
    ///     - grossPayPerMont: gross pay per month in entry
    /// - Returns: number of working days in period
    func addTestData(forPeriod period: Period,
                     workTimeInSec: Int,
                     overtimeInSec: Int,
                     standardWorkTimeInSec: Int,
                     maximumOvertimeInSec: Int,
                     grossPayPerMonth: Int) -> Int {
        let failMessage = "Add test data failed"
        guard let numberOfDays = Calendar.current.dateComponents([.day], from: period.0, to: period.1).day else {
            XCTFail(failMessage)
            return 0
        }
        var dateArray = [Date]()
        for i in 0..<numberOfDays {
            guard let date = Calendar.current.date(byAdding: .day, value: i, to: period.0) else {
                XCTFail(failMessage)
                return 0
            }
            dateArray.append(date)
        }
        var filteredArray = dateArray.filter { date in
            !Calendar.current.isDateInWeekend(date)
        }
        let resultArray = filteredArray.map { date in
            let startOfDate = Calendar.current.startOfDay(for: date)
            return Entry(
                startDate:  Calendar.current.date(byAdding: .hour, value: 8, to: startOfDate)!,
                finishDate: Calendar.current.date(byAdding: .hour, value: 16, to: startOfDate)!,
                workTimeInSec: workTimeInSec,
                overTimeInSec: overtimeInSec,
                maximumOvertimeAllowedInSeconds: maximumOvertimeInSec,
                standardWorktimeInSeconds: standardWorkTimeInSec,
                grossPayPerMonth: grossPayPerMonth,
                calculatedNetPay: nil
            )
        }
        for entry in resultArray {
            DataManager.testing.updateAndSave(entry: entry)
        }
        return resultArray.count
    }
}

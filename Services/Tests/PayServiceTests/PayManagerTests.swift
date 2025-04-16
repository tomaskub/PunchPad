//
//  PayManagerTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import ChartPeriodService
import CoreData
import DomainModels
import XCTest

@testable import PunchPad

final class PayManagerTests: XCTestCase {
    var sut: PayManager!
    var testContainer: TestContainer!
    var periodService: ChartPeriodService!
    
    override func setUp() {
        super.setUp()
        SettingsStore.setTestUserDefaults()
        testContainer = TestContainer()
        testContainer.dataManager.deleteAll()
        sut = .init(dataManager: testContainer.dataManager,
                    settingsStore: testContainer.settingsStore,
                    calendar: .current)
        periodService = ChartPeriodService(calendar: .current) // todo: replace with mock
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        testContainer = nil
    }
}

// MARK: TEST DATA GENERATION FOR PAST PERIODS
extension PayManagerTests {
    func testGenerateDataForPastWeek() {
        //Given
        guard let date = generateStableDate(),
              let testPeriod = try? periodService.generatePeriod(for: date, in: .week),
              let numberOfDayInMonth = numberOfWorkingDays(for: date) else {
            XCTFail("Failed to prepare test data in \(#function)")
            return
        }
        let expectedPayHour = Double(testContainer.settingsStore.grossPayPerMonth) / Double(numberOfDayInMonth * 8)
        let expectedNumberOfWorkingDays = 5
        let expectedPayToDate = expectedPayHour * 40
        _ = addTestData(forPeriod: testPeriod,
                        workTimeInSec: 8 * 3600,
                        overtimeInSec: 0, standardWorkTimeInSec: 8 * 3600,
                        maximumOvertimeInSec: 5 * 3600,
                        grossPayPerMonth: testContainer.settingsStore.grossPayPerMonth
        )
        //When
        sut.updatePeriod(with: testPeriod)
        //Then
        let result = sut.grossDataForPeriod
        XCTAssertEqual(result.numberOfWorkingDays, expectedNumberOfWorkingDays)
        XCTAssertEqual(result.payPerHour, expectedPayHour, accuracy: 0.01)
        XCTAssertEqual(result.payUpToDate, expectedPayToDate, accuracy: 0.01)
        XCTAssertNil(result.payPredicted)
    }
    
    func testGenerateDataForPastMonth() {
        //Given
        guard let date = generateStableDate(),
              let testPeriod = try? periodService.generatePeriod(for: date, in: .month),
              let numberOfWorkingDays = numberOfWorkingDays(for: date) else {
            XCTFail("Failed to prepare test data in \(#function)")
            return
        }
        let expectedPayHour = Double(testContainer.settingsStore.grossPayPerMonth) / Double(numberOfWorkingDays * 8)
        let expectedNumberOfWorkingDays = numberOfWorkingDays
        let expectedPayToDate = Double(testContainer.settingsStore.grossPayPerMonth)
        _ = addTestData(forPeriod: testPeriod,
                    workTimeInSec: 8 * 3600,
                    overtimeInSec: 0,
                    standardWorkTimeInSec: 8 * 3600,
                    maximumOvertimeInSec: 5 * 3600,
                    grossPayPerMonth: testContainer.settingsStore.grossPayPerMonth
        )
        //When
        sut.updatePeriod(with: testPeriod)
        //Then
        let result = sut.grossDataForPeriod
        XCTAssertEqual(result.numberOfWorkingDays, expectedNumberOfWorkingDays)
        XCTAssertEqual(result.payPerHour, expectedPayHour, accuracy: 0.01)
        XCTAssertEqual(result.payUpToDate, expectedPayToDate, accuracy: 0.01)
        XCTAssertNil(result.payPredicted)
    }
    
    func testGenerateDataForPastYear() {
        //Given
        guard let date = generateStableDate(),
              let testPeriod = try? periodService.generatePeriod(for: date, in: .year) else {
            XCTFail("Failed to prepare test data in \(#function)")
            return
        }
        let expectedNumberOfWorkingDays = numberOfWorkingDays(in: testPeriod)
        let expectedPayHour = Double(12 * testContainer.settingsStore.grossPayPerMonth) / Double(expectedNumberOfWorkingDays * 8)
        let expectedPayToDate = Double(12 * testContainer.settingsStore.grossPayPerMonth)
        _ = addTestData(forPeriod: testPeriod,
                    workTimeInSec: 8 * 3600,
                    overtimeInSec: 0,
                    standardWorkTimeInSec: 8 * 3600,
                    maximumOvertimeInSec: 5 * 3600,
                    grossPayPerMonth: testContainer.settingsStore.grossPayPerMonth
        )
        //When
        sut.updatePeriod(with: testPeriod)
        //Then
        let result = sut.grossDataForPeriod
        XCTAssertEqual(result.numberOfWorkingDays, expectedNumberOfWorkingDays)
        XCTAssertEqual(result.payPerHour, expectedPayHour, accuracy: 0.01)
        XCTAssertEqual(result.payUpToDate, expectedPayToDate, accuracy: 0.01)
        XCTAssertNil(result.payPredicted)
    }
}

// MARK: TEST DATA GENERATION FOR CURRENT PERIODS
extension PayManagerTests {
    // TODO: Fix flaky test - this test is not repeatable due to date of the run being used. For beigning of the week a pay predicted will not be avaliable, but if we have a possible prediction (for example we are mid-week) we will see a value.
    func testGeneratingDataForNotFinishedWeek() {
        //Given
        let date = Calendar.current.startOfDay(for: Date())
        guard let initialPeriod = try? periodService.generatePeriod(for: date, in: .week),
              let endOfToday = Calendar.current.date(byAdding: .day, value: 1, to: date),
              let numberOfWorkingDaysInMonth = numberOfWorkingDays(for: date) else {
            XCTFail("Failed to prepare test data in \(#function)")
            return
        }
        let dataPeriod = (initialPeriod.0, endOfToday)
        let expectedNumberOfWorkingDaysInPeriod = numberOfWorkingDays(in: initialPeriod)
        let expectedPayPerHour = Double(testContainer.settingsStore.grossPayPerMonth) / Double(numberOfWorkingDaysInMonth * 8)
        let expectedPayPrediced = expectedPayPerHour * Double(expectedNumberOfWorkingDaysInPeriod) * 8
        let expectedPayUpToDate = Double(numberOfWorkingDays(in: dataPeriod)) * 8 * expectedPayPerHour
        _ = addTestData(forPeriod: dataPeriod,
                    workTimeInSec: 8 * 3600,
                    overtimeInSec: 0,
                    standardWorkTimeInSec: 8 * 3600,
                    maximumOvertimeInSec: 5 * 3600,
                    grossPayPerMonth: testContainer.settingsStore.grossPayPerMonth
        )
        //When
        sut.updatePeriod(with: initialPeriod)
        //Then
        let result = sut.grossDataForPeriod
        XCTAssertEqual(result.numberOfWorkingDays, expectedNumberOfWorkingDaysInPeriod)
        XCTAssertEqual(result.payPerHour, expectedPayPerHour, accuracy: 0.01)
        XCTAssertNil(result.payPredicted)
        XCTAssertEqual(result.payUpToDate, expectedPayUpToDate, accuracy: 0.01)
    }
    
    func testGenerateDataForCurrentMonth() {
        //Given
        let date = Calendar.current.startOfDay(for: Date())
        guard let initialPeriod = try? periodService.generatePeriod(for: date, in: .month),
              let endOfToday = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
            XCTFail("Failed to prepare test data in \(#function)")
            return
        }
        let dataPeriod = (initialPeriod.0, endOfToday)
        let expectedNumberOfWorkingDaysInPeriod = numberOfWorkingDays(in: initialPeriod)
        let expectedPayPerHour = Double(testContainer.settingsStore.grossPayPerMonth) / Double(expectedNumberOfWorkingDaysInPeriod * 8)
        let expectedPayPrediced = expectedPayPerHour * Double(expectedNumberOfWorkingDaysInPeriod * 8)
        let expectedPayUpToDate = Double(numberOfWorkingDays(in: dataPeriod)) * 8 * expectedPayPerHour
        _ = addTestData(forPeriod: dataPeriod,
                    workTimeInSec: 8 * 3600,
                    overtimeInSec: 0,
                    standardWorkTimeInSec: 8 * 3600,
                    maximumOvertimeInSec: 5 * 3600,
                    grossPayPerMonth: testContainer.settingsStore.grossPayPerMonth
        )
        //When
        sut.updatePeriod(with: initialPeriod)
        //Then
        let result = sut.grossDataForPeriod
        XCTAssertEqual(result.numberOfWorkingDays, expectedNumberOfWorkingDaysInPeriod)
        XCTAssertEqual(result.payPerHour, expectedPayPerHour, accuracy: 0.01)
        XCTAssertEqual(result.payPredicted ?? 0, expectedPayPrediced, accuracy: 0.01)
        XCTAssertEqual(result.payUpToDate, expectedPayUpToDate, accuracy: 0.01)
    }
    
    func testGenerateDataForCurrentYear() {
        //Given
        let date = Calendar.current.startOfDay(for: Date())
        guard let initialPeriod = try? periodService.generatePeriod(for: date, in: .year),
              let endOfToday = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
            XCTFail("Failed to prepare test data in \(#function)")
            return
        }
        let dataPeriod = (initialPeriod.0, endOfToday)
        let expectedNumberOfWorkingDaysInPeriod = numberOfWorkingDays(in: initialPeriod)
        let expectedPayPerHour = Double(12 * testContainer.settingsStore.grossPayPerMonth) / Double(expectedNumberOfWorkingDaysInPeriod * 8)
        let expectedPayPrediced = Double(12 * testContainer.settingsStore.grossPayPerMonth)
        let addedEntries = addTestData(forPeriod: dataPeriod,
                    workTimeInSec: 8 * 3600,
                    overtimeInSec: 0,
                    standardWorkTimeInSec: 8 * 3600,
                    maximumOvertimeInSec: 5 * 3600,
                    grossPayPerMonth: testContainer.settingsStore.grossPayPerMonth
        )
        let expectedPayUpToDate: Double =
            addedEntries.map { [weak self] entry in
                guard let self else { return 0.0 }
                let numberOfWorkingDays = self.numberOfWorkingDays(for: entry.startDate)
                let grossPerHour = Double(entry.grossPayPerMonth) / Double((numberOfWorkingDays ?? 30) * 8)
                return grossPerHour * Double(entry.workTimeInSeconds) / 3600
            }.reduce(0, +)
        //When
        sut.updatePeriod(with: initialPeriod)
        //Then
        let result = sut.grossDataForPeriod
        XCTAssertEqual(result.numberOfWorkingDays, expectedNumberOfWorkingDaysInPeriod)
        XCTAssertEqual(result.payPerHour, expectedPayPerHour, accuracy: 0.01)
        XCTAssertEqual(result.payPredicted ?? 0, expectedPayPrediced, accuracy: 0.01)
        XCTAssertEqual(result.payUpToDate, expectedPayUpToDate, accuracy: 0.01)
    }
}

// MARK: TEST DATA GENERATION FOR FUTURE PERIODS
extension PayManagerTests {
    func testGeneratingDataForPeriodInFuture_withNoEntries() {
        //Given
        let date = Calendar.current.startOfDay(for: Date())
        guard let dateInFuture = Calendar.current.date(byAdding: .month, value: 1, to: date),
              let numberOfWorkingDaysInMonth = numberOfWorkingDays(for: dateInFuture),
              let period = try? periodService.generatePeriod(for: dateInFuture, in: .week) else {
            XCTFail("Failed to prepare test data in \(#function)")
            return
        }
        let expectedNumberOfWorkingDays = 5
        let expectedPayPerHour = Double(testContainer.settingsStore.grossPayPerMonth) / Double(numberOfWorkingDaysInMonth * 8)
        let expectedPayUpToDate: Double = 0
        //When
        sut.updatePeriod(with: period)
        //Then
        let result = sut.grossDataForPeriod
        XCTAssertEqual(result.numberOfWorkingDays, expectedNumberOfWorkingDays)
        XCTAssertEqual(result.payPerHour, expectedPayPerHour, accuracy: 0.01)
        XCTAssertEqual(result.payUpToDate, expectedPayUpToDate)
        XCTAssertNil(result.payPredicted)
    }
    
    func testGenerateDataForMonthPeriodInFuture() {
        //Given
        let date = Calendar.current.startOfDay(for: Date())
        guard let dateInFuture = Calendar.current.date(byAdding: .month, value: 1, to: date),
              let numberOfWorkingDaysInMonth = numberOfWorkingDays(for: dateInFuture),
              let period = try? periodService.generatePeriod(for: dateInFuture, in: .month) else {
            XCTFail("FAILED TO PREPARE INPUT DATA")
            return
        }
        let expectedPayPerHour = Double(testContainer.settingsStore.grossPayPerMonth) / (Double(numberOfWorkingDaysInMonth) * 8)
        let expectedNumberOfWorkingDays = numberOfWorkingDaysInMonth
        let expectedPayUpToDate: Double = 0
        //When
        sut.updatePeriod(with: period)
        //Then
        let result = sut.grossDataForPeriod
        XCTAssertEqual(result.numberOfWorkingDays, expectedNumberOfWorkingDays)
        XCTAssertEqual(result.payPerHour, expectedPayPerHour, accuracy: 0.01)
        XCTAssertEqual(result.payUpToDate, expectedPayUpToDate)
        XCTAssertNil(result.payPredicted)
    }
    
    func testGenerateDataForYearPeriodInFuture() {
        //Given
        let date = Calendar.current.startOfDay(for: Date())
        guard let dateInFuture = Calendar.current.date(byAdding: .year, value: 1, to: date),
              let period = try? periodService.generatePeriod(for: dateInFuture, in: .year) else {
            XCTFail("FAILED TO PREPARE INPUT DATA")
            return
        }
        let expectedNumberOfWorkingDays = numberOfWorkingDays(in: period)
        let expectedPayPerHour = Double(12 * testContainer.settingsStore.grossPayPerMonth) / Double(expectedNumberOfWorkingDays * 8)
        let expectedPayUpToDate: Double = 0
        //When
        sut.updatePeriod(with: period)
        //Then
        let result = sut.grossDataForPeriod
        XCTAssertEqual(result.numberOfWorkingDays, expectedNumberOfWorkingDays)
        XCTAssertEqual(result.payPerHour, expectedPayPerHour, accuracy: 0.01)
        XCTAssertEqual(result.payUpToDate, expectedPayUpToDate)
        XCTAssertNil(result.payPredicted)
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
    func addTestData(forPeriod period: Period,
                     workTimeInSec: Int,
                     overtimeInSec: Int,
                     standardWorkTimeInSec: Int,
                     maximumOvertimeInSec: Int,
                     grossPayPerMonth: Int) -> [Entry] {
        let failMessage = "Add test data failed"
        guard let numberOfDays = Calendar.current.dateComponents([.day], from: period.0, to: period.1).day else {
            XCTFail(failMessage)
            return []
        }
        var dateArray = [Date]()
        for i in 0..<numberOfDays {
            guard let date = Calendar.current.date(byAdding: .day, value: i, to: period.0) else {
                XCTFail(failMessage)
                return []
            }
            dateArray.append(date)
        }
        let resultArray = dateArray
            .filter { date in
                !Calendar.current.isDateInWeekend(date)
            }.map { date in
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
            testContainer.dataManager.updateAndSave(entry: entry)
        }
        return resultArray
    }
    
    /// Returns number of working days present in period based on current calendar
    func numberOfWorkingDays(in period: Period) -> Int {
        let calendar = Calendar.current
        guard let numberOfDays = calendar.dateComponents([.day], from: period.0, to: period.1).day else { return 0}
        let daysInPeriod = Array(0..<numberOfDays).map { i in
            calendar.date(byAdding: .day, value: i, to: period.0)!
        }
        let workingDays = daysInPeriod.filter { !calendar.isDateInWeekend($0) }
        return workingDays.count
    }
    
    /// Returns number of working days in month of the date
    func numberOfWorkingDays(for date: Date) -> Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .year], from: date)
        let startOfTheMonth = calendar.date(from: components)!
        guard let numberOfDays = calendar.range(of: .day, in: .month, for: startOfTheMonth)?.count else { return nil}
        let daysInMonth = Array(0..<numberOfDays).map { i in
            calendar.date(byAdding: .day, value: i, to: startOfTheMonth)!
        }
        let workDays = daysInMonth.filter({ !calendar.isDateInWeekend($0) })
        return workDays.count
    }
}

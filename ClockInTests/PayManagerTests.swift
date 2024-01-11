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
    
    func testGeneratingDataForNotFinishedPeriod() {
        //Given 
        let date = Calendar.current.startOfDay(for: Date())
        guard let initialPeriod = try? periodService.generatePeriod(for: date, in: .week),
              let endOfToday = Calendar.current.date(byAdding: .day, value: 1, to: date),
              let numberOfWorkingDaysInMonth = numberOfWorkingDays(for: date) else {
            XCTFail("FAILED TO PREPARE INPUT DATA")
            return
        }
        let expectedNumberOfWorkingDaysInPeriod = numberOfWorkingDays(in: initialPeriod)
        let dataPeriod = (initialPeriod.0, endOfToday)
        let dataDays = Calendar.current.dateComponents([.day], from: dataPeriod.0, to: dataPeriod.1)
        let numberOfAddedWorkingDays = addTestData(forPeriod: dataPeriod,
                                              workTimeInSec: 8 * 3600,
                                              overtimeInSec: 0,
                                              standardWorkTimeInSec: 8 * 3600,
                                              maximumOvertimeInSec: 5 * 3600,
                                              grossPayPerMonth: settingsStore.grossPayPerMonth)
        
        let expectedPayPerHour = Double(settingsStore.grossPayPerMonth) / (Double(numberOfWorkingDaysInMonth) * 8)
        let expectedPayPrediced = expectedPayPerHour * Double(expectedNumberOfWorkingDaysInPeriod) * 8
        let expectedPayUpToDate = Double(numberOfAddedWorkingDays) * 8 * expectedPayPerHour
        
        //When
        sut.updatePeriod(with: initialPeriod)
        //Then
        let result = sut.grossDataForPeriod
        XCTAssertEqual(result.payPerHour, expectedPayPerHour)
        XCTAssertEqual(result.numberOfWorkingDays, expectedNumberOfWorkingDaysInPeriod)
        XCTAssertEqual(result.payPredicted, expectedPayPrediced)
        XCTAssertEqual(result.payUpToDate, expectedPayUpToDate)
    }
    
    func testGeneratingDataForPeriodInFuture_withNoEntries() {
        //Given
        let date = Calendar.current.startOfDay(for: Date())
        guard let dateInFuture = Calendar.current.date(byAdding: .month, value: 1, to: date),
              let numberOfWorkingDaysInMonth = numberOfWorkingDays(for: dateInFuture),
              let period = try? periodService.generatePeriod(for: dateInFuture, in: .week) else {
            XCTFail("FAILED TO PREPARE INPUT DATA")
            return
        }
        let expectedPayPerHour = Double(settingsStore.grossPayPerMonth) / (Double(numberOfWorkingDaysInMonth) * 8)
        //When
        sut.updatePeriod(with: period)
        //Then
        let result = sut.grossDataForPeriod
        XCTAssertEqual(result.payPerHour, expectedPayPerHour)
        XCTAssertEqual(result.numberOfWorkingDays, 5)
        XCTAssertNil(result.payPredicted)
        XCTAssertEqual(result.payUpToDate, 0)
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
            DataManager.testing.updateAndSave(entry: entry)
        }
        return resultArray.count
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

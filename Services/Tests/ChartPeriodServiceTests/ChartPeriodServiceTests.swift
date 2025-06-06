//
//  ChartPeriodServiceTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 25/11/2023.
//

@testable import ChartPeriodService
import DomainModels
import XCTest
import XCTestExtensions

final class ChartPeriodServiceTests: XCTestCase, StableDateCreating {
    var sut: ChartPeriodService!
    var calendar: Calendar!
    var fixedCalendar: Calendar { calendar }
    
    override func setUp() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.firstWeekday = 2 // set Monday
        
        self.calendar = calendar
        sut = ChartPeriodService(calendar: fixedCalendar)
    }
    
    override func tearDown() {
        sut = nil
        calendar = nil
    }
}

// MARK: TEST FOR GENERATING PERIOD
extension ChartPeriodServiceTests {
    // NOTE ON DATE GENERATION IN TESTS
    /*
     Period service returns start of the day dates - hence,
     the finish of the period is a start of the next day to encompass whole day before
     */
    func test_generatePeriod_forMonth() throws {
        // Given
        guard let inputDate = createDate(year: 2023, month: 11, day: 20),
              let startDate = createDate(year: 2023, month: 11, day: 1),
              let finishDate = createDate(year: 2023, month: 12, day: 1) else {
            XCTFail("Failed to generate input and predicted output dates")
            return
        }
        let expectedResult = (startDate, finishDate)
        
        // When
        let result = try sut.generatePeriod(for: inputDate, in: .month)
        
        // Then
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssert(result.1 == expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_generatePeriod_forWeek() throws {
        // Given
        guard let inputDate = createDate(year: 2023, month: 11, day: 22),
              let startDate = createDate(year: 2023, month: 11, day: 20),
              let finishDate = createDate(year: 2023, month: 11, day: 27) else {
            XCTFail("Failed to generate input and predicted output dates")
            return
        }
        let expectedResult = (startDate, finishDate)
        
        // When
        let result = try sut.generatePeriod(for: inputDate, in: .week)
        
        // Then
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssertEqual(result.1, expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_generatePeriod_forYear() throws {
        // Given
        guard let inputDate = createDate(year: 2023, month: 11, day: 20),
              let startDate = createDate(year: 2023, month: 1, day: 1),
              let finishDate = createDate(year: 2024, month: 1, day: 1) else {
            XCTFail("Failed to generate input and predicted output dates")
            return
        }
        let expectedResult = (startDate, finishDate)
        
        // When
        let result = try sut.generatePeriod(for: inputDate, in: .year)
        
        // Then
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssert(result.1 == expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_generatePeriod_forAll_throwsError() {
        // Given
        guard let inputDate = createDate(year: 2023, month: 11, day: 20) else {
            XCTFail("Failed to generate input date")
            return
        }
        
        // Then
        XCTAssertThrowsError(try sut.generatePeriod(for: inputDate, in: .all), "Function should throw error") { error in
            XCTAssertEqual(error as? ChartPeriodServiceError, .attemptedToRetrievePeriodForAll, "Error thrown should be `.attemptedToRetrievePeriodForAll`")
        }
        
    }
}

// MARK: TESTS FOR RETARDING PERIOD
extension ChartPeriodServiceTests {
    func test_RetardingPeriodForWeek() throws {
        // Given
        guard let inputStartDate = createDate(year: 2023, month: 11, day: 20),
              let inputFinishDate = createDate(year: 2023, month: 11, day: 27),
              let expectedStartDate = createDate(year: 2023, month: 11, day: 13),
              let expectedFinishDate = createDate(year: 2023, month: 11, day: 20) else {
            XCTFail("Failed to generate input and predicted output dates")
            return
        }
        let inputPeriod: Period = (inputStartDate, inputFinishDate)
        let expectedResult: Period = (expectedStartDate, expectedFinishDate)
        
        // When
        let result = try sut.retardPeriod(by: .week, from: inputPeriod)
        
        // Then
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssertEqual(result.1, expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_RetardingPeriodForMonth() throws {
        // Given
        guard let inputStartDate = createDate(year: 2023, month: 11, day: 1),
              let inputFinishDate = createDate(year: 2023, month: 12, day: 1),
              let expectedStartDate = createDate(year: 2023, month: 10, day: 1),
              let expectedFinishDate = createDate(year: 2023, month: 11, day: 1) else {
                XCTFail("Failed to generate input and predicted output dates")
                return
            }
        let inputPeriod: Period = (inputStartDate, inputFinishDate)
        let expectedResult: Period = (expectedStartDate, expectedFinishDate)
        
        // When
        let result = try sut.retardPeriod(by: .month, from: inputPeriod)

        // Then
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssertEqual(result.1, expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_RetardingPeriodForYear() throws {
        // Given
        guard let inputStartDate = createDate(year: 2023, month: 1, day: 1),
              let inputFinishDate = createDate(year: 2024, month: 1, day: 1),
              let expectedStartDate = createDate(year: 2022, month: 1, day: 1),
              let expectedFinishDate = createDate(year: 2023, month: 1, day: 1) else {
                XCTFail("Failed to generate input and predicted output dates")
                return
            }
        let inputPeriod: Period = (inputStartDate, inputFinishDate)
        let expectedResult: Period = (expectedStartDate, expectedFinishDate)
        
        // When
        let result = try sut.retardPeriod(by: .year, from: inputPeriod)
        
        // Then
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssertEqual(result.1, expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_RetardingPeriodForAll_throwsError() throws {
        // Given
        guard let inputStartDate = createDate(year: 2023, month: 1, day: 1),
              let inputFinishDate = createDate(year: 2023, month: 12, day: 31) else {
            XCTFail("Failed to generate input and predicted output dates")
            return
        }
        let inputPeriod: Period = (inputStartDate, inputFinishDate)
        
        XCTAssertThrowsError(try sut.retardPeriod(by: .all, from: inputPeriod), "Function should throw") { error in
            XCTAssertEqual(error as? ChartPeriodServiceError, .attemptedToRetrievePeriodForAll, "Error thrown should be `.attemptedToRetrievePeriodForAll`")
        }
    }
}

// MARK: TESTS FOR ADVANCING PERIOD
extension ChartPeriodServiceTests {
    func test_advancingPeriodForWeek() throws {
        // Given
        guard let inputStartDate = createDate(year: 2023, month: 11, day: 13),
              let inputFinishDate = createDate(year: 2023, month: 11, day: 20),
              let expectedStartDate = createDate(year: 2023, month: 11, day: 20),
              let expectedFinishDate = createDate(year: 2023, month: 11, day: 27) else {
                XCTFail("Failed to generate input and predicted output dates")
                return
            }
        let inputPeriod: Period = (inputStartDate, inputFinishDate)
        let expectedResult: Period = (expectedStartDate, expectedFinishDate)
        
        // When
        let result = try sut.advancePeriod(by: .week, from: inputPeriod)
        
        // Then
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssertEqual(result.1, expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_advancingPeriodForMonth() throws {
        // Given
        guard let inputStartDate = createDate(year: 2023, month: 10, day: 1),
              let inputFinishDate = createDate(year: 2023, month: 11, day: 1),
              let expectedStartDate = createDate(year: 2023, month: 11, day: 1),
              let expectedFinishDate = createDate(year: 2023, month: 12, day: 1) else {
                XCTFail("Failed to generate input and predicted output dates")
                return
            }
        let inputPeriod: Period = (inputStartDate, inputFinishDate)
        let expectedResult: Period = (expectedStartDate, expectedFinishDate)
        
        // When
        let result = try sut.advancePeriod(by: .month, from: inputPeriod)
        
        // Then
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssertEqual(result.1, expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_advancingPeriodForYear() throws {
        // Given
        guard let inputStartDate = createDate(year: 2022, month: 1, day: 1),
              let inputFinishDate = createDate(year: 2023, month: 1, day: 1),
              let expectedStartDate = createDate(year: 2023, month: 1, day: 1),
              let expectedFinishDate = createDate(year: 2024, month: 1, day: 1) else {
                XCTFail("Failed to generate input and predicted output dates")
                return
            }
        let inputPeriod: Period = (inputStartDate, inputFinishDate)
        let expectedResult: Period = (expectedStartDate, expectedFinishDate)
        
        // When
        let result = try sut.advancePeriod(by: .year, from: inputPeriod)
        
        // Then
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssertEqual(result.1, expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_advancingPeriodForAll_throwsError() throws {
        // Given
        guard let inputStartDate = createDate(year: 2023, month: 1, day: 1),
              let inputFinishDate = createDate(year: 2023, month: 12, day: 31) else {
            XCTFail("Failed to generate input and predicted output dates")
            return
        }
        let inputPeriod: Period = (inputStartDate, inputFinishDate)
        
        XCTAssertThrowsError(try sut.advancePeriod(by: .all, from: inputPeriod), "Function should throw") { error in
            XCTAssertEqual(
                error as? ChartPeriodServiceError,
                .attemptedToRetrievePeriodForAll,
                "Error thrown should be `.attemptedToRetrievePeriodForAll`"
            )
        }
    }
}

//
//  ChartPeriodServiceTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 25/11/2023.
//

import XCTest
@testable import ClockIn
final class ChartPeriodServiceTests: XCTestCase {
    
    var sut: ChartPeriodService!
    
    override func setUp() {
        sut = ChartPeriodService(calendar: .current)
    }
    
    override func tearDown() {
        sut = nil
    }
}

//MARK: TEST FOR GENERATING PERIOD
extension ChartPeriodServiceTests {
    func test_generatePeriod_forMonth() throws {
        // Given
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
        
        // When
        let result = try sut.generatePeriod(for: inputDate, in: .month)
        
        //Then
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssert(result.1 == expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_generatePeriod_forWeek() throws {
        // Given
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
        let expectedResult = (startDate, finishDate)
        
        // When
        let result = try sut.generatePeriod(for: inputDate, in: .week)
        
        // Then
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssertEqual(result.1, expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_generatePeriod_forYear() throws {
        // Given
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
        let expectedResult = (startDate, finishDate)
        
        // When
        let result = try sut.generatePeriod(for: inputDate, in: .year)
        
        // Then
        XCTAssertEqual(result.0, expectedResult.0, "Start date is \(result.0), and it should be \(expectedResult.0)")
        XCTAssert(result.1 == expectedResult.1, "Finish date is \(result.1), and it should be \(expectedResult.1)")
    }
    
    func test_generatePeriod_forAll_throwsError() {
        // Given
        let inputDate = {
            let dateComponents = DateComponents(year: 2023, month: 11, day: 20)
            return Calendar.current.date(from: dateComponents)
        }()
        guard let inputDate else {
            XCTFail("Failed to generate input date")
            return
        }
        
        // Then
        XCTAssertThrowsError(try sut.generatePeriod(for: inputDate, in: .all), "Function should throw error") { error in
            XCTAssertEqual(error as? ChartPeriodServiceError, .attemptedToRetrievePeriodForAll, "Error thrown should be `.attemptedToRetrievePeriodForAll`")
        }
        
    }
}

//MARK: TESTS FOR RETARDING PERIOD
extension ChartPeriodServiceTests {
    func test_RetardingPeriodForWeek() throws {
        // Given
        guard let inputStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 20)),
              let inputFinishDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 26)),
              let expectedStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 13)),
              let expectedFinishDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 19)) else {
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
        guard let inputStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 1)),
              let inputFinishDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 30)),
              let expectedStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 1)),
              let expectedFinishDate = Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 31)) else {
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
        guard let inputStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1)),
              let inputFinishDate = Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 31)),
              let expectedStartDate = Calendar.current.date(from: DateComponents(year: 2022, month: 1, day: 1)),
              let expectedFinishDate = Calendar.current.date(from: DateComponents(year: 2022, month: 12, day: 31)) else {
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
        guard let inputStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1)),
              let inputFinishDate = Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 31)) else {
            XCTFail("Failed to generate input and predicted output dates")
            return
        }
        let inputPeriod: Period = (inputStartDate, inputFinishDate)
        
        XCTAssertThrowsError(try sut.retardPeriod(by: .all, from: inputPeriod), "Function should throw") { error in
            XCTAssertEqual(error as? ChartPeriodServiceError, .attemptedToRetrievePeriodForAll, "Error thrown should be `.attemptedToRetrievePeriodForAll`")
        }
    }
}

//MARK: TESTS FOR ADVANCING PERIOD
extension ChartPeriodServiceTests {
    func test_advancingPeriodForWeek() throws {
        // Given
        guard let inputStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 13)),
              let inputFinishDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 19)),
              let expectedStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 20)),
              let expectedFinishDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 26)) else {
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
        guard let inputStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 1)),
              let inputFinishDate = Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 31)),
              let expectedStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 1)),
              let expectedFinishDate = Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 30)) else {
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
        guard let inputStartDate = Calendar.current.date(from: DateComponents(year: 2022, month: 1, day: 1)),
              let inputFinishDate = Calendar.current.date(from: DateComponents(year: 2022, month: 12, day: 31)),
              let expectedStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1)),
              let expectedFinishDate = Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 31)) else {
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
        guard let inputStartDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1)),
              let inputFinishDate = Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 31)) else {
            XCTFail("Failed to generate input and predicted output dates")
            return
        }
        let inputPeriod: Period = (inputStartDate, inputFinishDate)
        
        XCTAssertThrowsError(try sut.advancePeriod(by: .all, from: inputPeriod), "Function should throw") { error in
            XCTAssertEqual(error as? ChartPeriodServiceError, .attemptedToRetrievePeriodForAll, "Error thrown should be `.attemptedToRetrievePeriodForAll`")
        }
    }
}

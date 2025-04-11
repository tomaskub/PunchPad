//
//  EditSheetViewModelTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 21/12/2023.
//
import DomainModels
import XCTest
@testable import PunchPad

final class EditSheetViewModelTests: XCTestCase {
    var sut: EditSheetViewModel!
    var testContainer: TestContainer!
    let entry: Entry = {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let startDate = Calendar.current.date(byAdding: .hour, value: 6, to: startOfDay)!
        let finishDate = Calendar.current.date(byAdding: .minute,
                                               value: 9 * 60 + 30,
                                               to: startDate)!
        return Entry(startDate: startDate,
                     finishDate: finishDate,
                     workTimeInSec: 8*3600,
                     overTimeInSec: 3600 + 1800,
                     maximumOvertimeAllowedInSeconds: 5*3600,
                     standardWorktimeInSeconds: 8*3600,
                     grossPayPerMonth: 10000,
                     calculatedNetPay: nil)
    }()
    
    override func setUp() {
        testContainer = TestContainer()
        SettingsStore.setTestUserDefaults()
        sut = .init(dataManager: testContainer.dataManager,
                    settingsStore: testContainer.settingsStore,
                    payService: PayManager(dataManager: testContainer.dataManager,
                                           settingsStore: testContainer.settingsStore,
                                           calendar: .current),
                    calendar: .current,
                    entry: entry)
    }

    override func tearDown() {
        SettingsStore.clearUserDefaults()
        sut = nil
        testContainer = nil
    }

    func test_adjustToEqualDateComponents() throws {
        //Given
        sut.shouldDisplayFullDates = true
        let finishDatePublisher = sut.$finishDate
            .first()
            .eraseToAnyPublisher()
        
        guard let inputDate = Calendar.current.date(byAdding: .day, value: -1, to: sut.startDate),
              let expectedFinishDate = Calendar.current.date(byAdding: .day, value: -1, to: sut.finishDate) else {
            XCTFail("Failed to generate input and expected date in \(#file), function: \(#function), at line \(#line)")
            return
        }
        
        //When
        sut.startDate = inputDate
        sut.shouldDisplayFullDates = false

        //Then
        let result = try awaitPublisher(finishDatePublisher)
        let resultFinishDate = try XCTUnwrap(result)
        XCTAssertEqual(expectedFinishDate, resultFinishDate, "Dates should be equal")
    }
}

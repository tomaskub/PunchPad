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
    var container: Container!
    override func setUp() {
        super.setUp()
        container = Container()
        sut = .init(dataManager: container.dataManager,
                    settingsStore: container.settingsStore)
    }

    override func tearDown() {
        super.tearDown()
        DataManager.testing.deleteAll()
        sut = nil
    }
    
    func testGetNumberOfWorkingDays() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let dateString = "April 16, 2023"
        
        
        guard let date = formatter.date(from: dateString) else {
            XCTFail("Failed to build date from given string")
            return
        }
        
        let numberOfDays = sut.getNumberOfWorkingDays(inMonthOfDate: date)
        
        XCTAssert(numberOfDays == 20, "Number of working days should be 20" )
    }
    
    func testCalculateGrossPay_whenNoDateIsGiven() {
        //Add entries to memory
        let components = Calendar.current.dateComponents([.month, .year], from: Date())
        
        guard let startOfTheMonth = Calendar.current.date(from: components) else {
            XCTFail()
            return
        }
        
        for i in 1...5 {
            let date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: i, to: startOfTheMonth)!)
            let entry = Entry(
                startDate:  Calendar.current.date(byAdding: .hour, value: 8, to: date)!,
                finishDate: Calendar.current.date(byAdding: .hour, value: 16, to: date)!,
                workTimeInSec: 8 * 3600,
                overTimeInSec: 0,
                maximumOvertimeAllowedInSeconds: 5*3600,
                standardWorktimeInSeconds: 8*3600,
                grossPayPerMonth: container.settingsStore.grossPayPerMonth,
                calculatedNetPay: nil)
            DataManager.testing.updateAndSave(entry: entry)
        }
        
        let pay = sut.grossPayPerHour
        let numberOfHours: Double = 40
        let correctResult = numberOfHours * pay
        
        let result = sut.calculateGrossPay()
        XCTAssert(result == correctResult, "Result from function should be equal to \(correctResult)")
    }
}

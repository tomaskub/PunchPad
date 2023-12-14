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
    
    override func setUp() {
        super.setUp()
        sut = .init(dataManager: DataManager.testing, settingsStore: SettingsStore())
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testGetNumberOfWorkingDays() {
        
        let formatter = Date.FormatStyle()
            .year(.defaultDigits)
            .month(.wide)
            .day(.defaultDigits)
        let dateString = "April 16, 2023"
        
        do {
            let date = try formatter.parse(dateString)
            
            let numberOfDays = sut.getNumberOfWorkingDays(inMonthOfDate: date)
            
            XCTAssert(numberOfDays == 20, "Number of working days should be 20" )
            
        } catch {
            XCTFail(error.localizedDescription)
        }
        
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
                grossPayPerMonth: 10000,
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

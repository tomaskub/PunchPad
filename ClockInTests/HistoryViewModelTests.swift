//
//  HistoryViewModelTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/8/23.
//

import XCTest
import CoreData
@testable import ClockIn

final class HistoryViewModelTests: XCTestCase {

    var sut: HistoryViewModel!
    
    
    override func setUp() {
        super.setUp()
        sut = .init(dataManager: DataManager.testing, settingsStore: SettingsStore())
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    

    func testTimeWorkedLabel_withNormalDate() {
        let startDate = Calendar.current.date(byAdding: .hour, value: -7 , to: Date())!
        let finishDate = Calendar.current.date(byAdding: .hour, value: 2 , to: Date())!
        let entry = Entry(startDate: startDate, finishDate: finishDate, workTimeInSec: 8 * 3600, overTimeInSec: Int(1.5 * 3600))
        
        let result = sut.timeWorkedLabel(for: entry)
        
        XCTAssertEqual(result, "09 hours 30 minutes")
    }
    
    func testConvertOvertimeToFraction_for2hours30minutes() {
        let startDate = Calendar.current.date(byAdding: .hour, value: -7 , to: Date())!
        let finishDate = Calendar.current.date(byAdding: .hour, value: 2 , to: Date())!
        let entry = Entry(startDate: startDate, finishDate: finishDate, workTimeInSec: 8 * 3600, overTimeInSec: Int(2.5 * 3600))
        
        let result = sut.convertOvertimeToFraction(entry: entry)
        
        XCTAssertTrue(result == 0.5, "Results should be 0.5")
        
    }
    
    func testConvertWorkTimeToFraction_for4hours() {
        let startDate = Calendar.current.date(byAdding: .hour, value: -7 , to: Date())!
        let finishDate = Calendar.current.date(byAdding: .hour, value: 2 , to: Date())!
        let entry = Entry(startDate: startDate, finishDate: finishDate, workTimeInSec: 4 * 3600, overTimeInSec: 0)
        
        let result = sut.convertWorkTimeToFraction(entry: entry)
        
        XCTAssertTrue(result == 0.5, "Results should be 0.5")
        
    }
    //Extra tests from the default setup
    /*
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
     */
}

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
    var container: Container!
    
    override func setUp() {
        super.setUp()
        container = .init()
        sut = .init(dataManager: container.dataManager,
                    settingsStore: container.settingsStore
        )
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func test_groupingEntries() {
        sut = nil
        let calendar = Calendar.current
        guard let date = calendar.date(from: DateComponents(year: 2023, month: 12)) else { XCTFail(); return }
        
        let entries = PreviewDataFactory.buildDataForPreviewForYear(containing: date, using: calendar)
        
        for entry in entries {
            container.dataManager.updateAndSave(entry: entry)
        }
        
        sut = .init(dataManager: container.dataManager,
                    settingsStore: container.settingsStore,
                    sizeOfChunk: nil)
        
        XCTAssertEqual(sut.groupedEntries.count, 12)
        for (i, monthArray) in sut.groupedEntries.enumerated() {
            let correctMonthNumber = i + 1
            for entry in monthArray {
                let monthNumber = calendar.dateComponents([.month], from: entry.startDate).month
                XCTAssertEqual(correctMonthNumber, correctMonthNumber, "Month number should be 1 more than array index")
            }
        }
    }
    
    func test_loadingInitialEntries() {
        sut = nil
        let calendar = Calendar.current
        guard let date = calendar.date(from: DateComponents(year: 2023, month: 12)) else { XCTFail(); return }
        
        let entries = PreviewDataFactory.buildDataForPreviewForYear(containing: date, using: calendar)
        
        for entry in entries {
            container.dataManager.updateAndSave(entry: entry)
        }
        let chunkSize = 15
        sut = .init(dataManager: container.dataManager,
                    settingsStore: container.settingsStore,
                    sizeOfChunk: chunkSize)
        XCTAssertEqual(sut.groupedEntries.flatMap({ $0 }).count, 15, "Number of entries should be equal to set chunk size")
    }
    
    func test_LoadingMoreItems() {
        sut = nil
        let calendar = Calendar.current
        guard let date = calendar.date(from: DateComponents(year: 2023, month: 12)) else { XCTFail(); return }
        
        let entries = PreviewDataFactory.buildDataForPreviewForYear(containing: date, using: calendar)
        
        for entry in entries {
            container.dataManager.updateAndSave(entry: entry)
        }
        
        let chunkSize = 15
        sut = .init(dataManager: container.dataManager,
                    settingsStore: container.settingsStore,
                    sizeOfChunk: chunkSize)
        sut.loadMoreItems()
        XCTAssertEqual(sut.groupedEntries.flatMap({ $0 }).count, chunkSize * 2, "Number of entries should be equal to two times chunk size")
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
        let entry = Entry(startDate: startDate,
                          finishDate: finishDate,
                          workTimeInSec: 4 * 3600,
                          overTimeInSec: 0)
        
        let result = sut.convertWorkTimeToFraction(entry: entry)
        
        XCTAssertTrue(result == 0.5, "Results should be 0.5")
    }
}

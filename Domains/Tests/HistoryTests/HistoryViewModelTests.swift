//
//  HistoryViewModelTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/8/23.
//

import CoreData
import ContainerService
import UIComponents
import XCTest

@testable import History

final class HistoryViewModelTests: XCTestCase {

    var sut: HistoryViewModel!
    var container: TestContainer!
    
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
        container.dataManager.deleteAll()
        container = nil
    }
    
    func test_groupingEntries() {
        // Given
        sut = nil
        let calendar = Calendar.current
        guard let date = calendar.date(from: DateComponents(year: 2023, month: 12)) else { XCTFail(); return }
        container.dataManager.deleteAll() // TODO: refactor cleaning data before tests
        
        PreviewDataFactory.buildDataForPreviewForYear(
            containing: date,
            using: calendar
        ).forEach {
            container.dataManager.updateAndSave(entry: $0)
        }
        
        // When
        sut = .init(dataManager: container.dataManager,
                    settingsStore: container.settingsStore,
                    sizeOfChunk: nil)
        
        // Then
        XCTAssertEqual(sut.groupedEntries.count, 12)
        
        for (monthNumber, monthArray) in sut.groupedEntries.enumerated() {
            let correctMonthNumber = 12 - monthNumber
            for entry in monthArray {
                let monthNumber = calendar.dateComponents([.month], from: entry.startDate).month
                XCTAssertEqual(monthNumber, correctMonthNumber, "Month number should be 1 more than array index")
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
    
    func test_applyFilters() {
        sut = nil
        let calendar = Calendar.current
        guard let date = calendar.date(from: DateComponents(year: 2023, month: 12)) else { XCTFail(); return }
        
        let entries = PreviewDataFactory.buildDataForPreviewForYear(containing: date, using: calendar)
        
        for entry in entries {
            container.dataManager.updateAndSave(entry: entry)
        }
        let chunkSize = 30
        sut = .init(dataManager: container.dataManager,
                    settingsStore: container.settingsStore,
                    sizeOfChunk: chunkSize)
        guard let fromDate =  calendar.date(from: DateComponents(year: 2023, month: 11, day: 6)),
              let toDate = calendar.date(from: DateComponents(year: 2023, month: 11, day: 11)) else {
            XCTFail()
            return
        }
        sut.filterFromDate = fromDate
        sut.filterToDate = toDate
        sut.applyFilters()
        XCTAssertEqual(sut.isSortingActive, true, "Sorting shoud be active")
        XCTAssertEqual(sut.groupedEntries.flatMap({ $0 }).count, 5, "There should be 5 entries")
        
    }
    
    func test_resetFilters() {
        sut = nil
        let calendar = Calendar.current
        guard let date = calendar.date(from: DateComponents(year: 2023, month: 12)) else { XCTFail(); return }
        
        let entries = PreviewDataFactory.buildDataForPreviewForYear(containing: date, using: calendar)
        
        for entry in entries {
            container.dataManager.updateAndSave(entry: entry)
        }
        let chunkSize = 30
        sut = .init(dataManager: container.dataManager,
                    settingsStore: container.settingsStore,
                    sizeOfChunk: chunkSize)
        guard let fromDate =  calendar.date(from: DateComponents(year: 2023, month: 12, day: 4)),
              let toDate = calendar.date(from: DateComponents(year: 2023, month: 12, day: 8)) else {
            XCTFail()
            return
        }
        sut.filterFromDate = fromDate
        sut.filterToDate = toDate
        sut.applyFilters()
        
        sut.resetFilters()
        XCTAssertEqual(
            sut.groupedEntries.flatMap({ $0 }).count,
            chunkSize,
            "Number of entries should be equal to two times chunk size"
        )
        
    }
}

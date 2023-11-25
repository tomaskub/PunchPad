//
//  StatisticsViewModelTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/21/23.
//

import XCTest
import CoreData
@testable import ClockIn

final class StatisticsViewModelTests: XCTestCase {

    var sut: StatisticsViewModel!
    var container: Container!
    override func setUp() {
        container = Container()
        let settingsStore = SettingsStore()
        sut = StatisticsViewModel(dataManager: container.dataManager,
                                  payManager: container.payManager,
                                  settingsStore: container.settingsStore)
    }

    override func tearDown() {
        sut = nil
    }

    func testEntriesForChart() {
        
        let dataManager = DataManager.testing
        
        dataManager.updateAndSave(entry: Entry(
            startDate: Calendar.current.date(byAdding: .hour, value: -8, to: Date())!,
            finishDate: Date(),
            workTimeInSec: 8 * 3600,
            overTimeInSec: 0))
        let correctValue: Int = {
            let components = Calendar.current.dateComponents([.month, .year], from: Date())
            let startOfTheMonth = Calendar.current.date(from: components)!
            return Calendar.current.range(of: .day, in: .month, for: startOfTheMonth)!.count
        }()
        
        let result = sut.entriesForChart
        XCTAssert(result.count == correctValue, "There should be 7 objects in the array")
    }
    
}

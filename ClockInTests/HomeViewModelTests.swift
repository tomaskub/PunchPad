//
//  TimerModelTests.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/12/23.
//

import XCTest
@testable import ClockIn

final class HomeViewModelModelTests: XCTestCase {
    
    var sut: HomeViewModel!
    var settingsStore: SettingsStore!
    
    override func setUp() {
        super.setUp()
        SettingsStore.setTestUserDefaults()
        self.settingsStore = SettingsStore()
        sut = .init(HomeViewModel(dataManager: DataManager.testing,
                                  settingsStore: settingsStore,
                                  payManager: PayManager(dataManager: DataManager.testing, settingsStore: settingsStore),
                                  timerProvider: MockTimer.self)
        )
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}

//
//  TestContainer.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 16/04/2024.
//

import Foundation
import OSLog

final class TestContainer: ContainerProtocol {
    private(set) var dataManager: any DataManaging
    private(set) var payManager: PayManager
    private(set) var timerProvider: Timer.Type
    private(set) var settingsStore: SettingsStore
    private(set) var notificationService: NotificationService
    private let logger = Logger.containerService
    
    init() {
        logger.debug("Initializing test container")
        SettingsStore.setTestUserDefaults()
        self.timerProvider = Timer.self
        self.settingsStore = SettingsStore()
        self.dataManager = TestDataManager()
        self.payManager = PayManager(dataManager: dataManager,
                                     settingsStore: settingsStore,
                                     calendar: .current)
        self.notificationService = NotificationService(center: .current())
    }
}

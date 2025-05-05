//
//  TestContainer.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 16/04/2024.
//

import Foundation
import NotificationService
import OSLog
import PayService
import Persistance
import SettingsService

public final class TestContainer: ContainerProtocol {
    public private(set) var dataManager: any DataManaging
    public private(set) var payManager: PayManager
    public private(set) var timerProvider: Timer.Type
    public private(set) var settingsStore: SettingsStore
    public private(set) lazy var notificationService: NotificationService = {
        NotificationService(
            center: WrappedUNUserNotificationCenter(center: .current())
        )
    }()
    private let logger = Logger.containerService
    
    public init() {
        logger.debug("Initializing test container")
        SettingsStore.setTestUserDefaults()
        self.timerProvider = Timer.self
        self.settingsStore = SettingsStore()
        self.dataManager = TestDataManager()
        self.payManager = PayManager(dataManager: dataManager,
                                     settingsStore: settingsStore,
                                     calendar: .current)
    }
}

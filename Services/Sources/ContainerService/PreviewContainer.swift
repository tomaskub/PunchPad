//
//  PreviewContainer.swift
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

public final class PreviewContainer: ContainerProtocol {
    public private(set) var dataManager: any DataManaging
    public private(set) var payManager: PayManager
    public private(set) var timerProvider: Timer.Type
    public private(set) var settingsStore: SettingsStore
    public private(set) var notificationService: NotificationService
    private let logger = Logger.containerService
    
    public init() {
        logger.debug("Initializing preview container")
        SettingsStore.setTestUserDefaults()
        self.timerProvider = Timer.self
        self.settingsStore = SettingsStore()
        self.dataManager = PreviewDataManager()
        self.payManager = PayManager(dataManager: dataManager,
                                     settingsStore: settingsStore,
                                     calendar: .current)
        self.notificationService = NotificationService(
            center: WrappedUNUserNotificationCenter(center: .current())
        )
    }
}

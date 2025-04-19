//
//  Container.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 12/09/2023.
//

import Foundation
import NotificationService
import OSLog
import PayService
import Persistance
import SettingsService

public final class Container: ContainerProtocol {
    public private(set) var dataManager: any DataManaging
    public private(set) var payManager: PayManager
    public private(set) var timerProvider: Timer.Type
    public private(set) var settingsStore: SettingsStore
    public private(set) var notificationService: NotificationService
    private let logger = Logger.containerService
    
    public init() {
        logger.debug("Initializing production container")
        self.timerProvider = Timer.self
        self.settingsStore = SettingsStore()
        self.dataManager = DataManager()
        self.payManager = PayManager(dataManager: dataManager,
                                     settingsStore: settingsStore,
                                     calendar: Calendar.current)
        self.notificationService = NotificationService(center: .current())
    }
}

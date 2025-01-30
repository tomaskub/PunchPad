//
//  Container.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 12/09/2023.
//

import Foundation
import OSLog

final class Container: ContainerProtocol {
    private(set) var dataManager: any DataManaging
    private(set) var payManager: PayManager
    private(set) var timerProvider: Timer.Type
    private(set) var settingsStore: SettingsStore
    private(set) var notificationService: NotificationService
    private let logger = Logger.containerService
    
    init(dataManaging: DataManaging = DataManager()) {
        logger.debug("Initializing production container")
        self.timerProvider = Timer.self
        self.settingsStore = SettingsStore()
        self.dataManager = dataManaging
        self.payManager = PayManager(dataManager: dataManager,
                                     settingsStore: settingsStore,
                                     calendar: .current)
        self.notificationService = NotificationService(center: .current())
    }
}


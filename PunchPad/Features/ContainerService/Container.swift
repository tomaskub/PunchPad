//
//  Container.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 12/09/2023.
//

import Foundation

final class Container: ContainerProtocol {
    private(set) var dataManager: DataManager
    private(set) var payManager: PayManager
    private(set) var timerProvider: Timer.Type
    private(set) var settingsStore: SettingsStore
    private(set) var notificationService: NotificationService
    
    init() {
        self.timerProvider = Timer.self
        self.settingsStore = SettingsStore()
        self.dataManager = .shared
        self.payManager = PayManager(dataManager: .shared, settingsStore: settingsStore, calendar: .current)
        self.notificationService = NotificationService(center: .current())
    }
}


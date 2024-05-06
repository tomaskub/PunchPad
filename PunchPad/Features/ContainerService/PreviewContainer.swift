//
//  PreviewContainer.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 16/04/2024.
//

import Foundation

final class PreviewContainer: ContainerProtocol {
    private(set) var dataManager: any DataManaging
    private(set) var payManager: PayManager
    private(set) var timerProvider: Timer.Type
    private(set) var settingsStore: SettingsStore
    private(set) var notificationService: NotificationService
    
    init() {
        SettingsStore.setTestUserDefaults()
        self.timerProvider = Timer.self
        self.settingsStore = SettingsStore()
        self.dataManager = PreviewDataManager()
        self.payManager = PayManager(dataManager: dataManager,
                                     settingsStore: settingsStore,
                                     calendar: .current)
        self.notificationService = NotificationService(center: .current())
    }
}

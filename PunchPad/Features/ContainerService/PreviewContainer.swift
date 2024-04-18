//
//  PreviewContainer.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 16/04/2024.
//

import Foundation

final class PreviewContainer: ContainerProtocol {
    private(set) var dataManager: DataManager
    private(set) var payManager: PayManager
    private(set) var timerProvider: Timer.Type
    private(set) var settingsStore: SettingsStore
    private(set) var notificationService: NotificationService
    
    init() {
        self.timerProvider = Timer.self
        SettingsStore.setTestUserDefaults()
        self.settingsStore = SettingsStore()
        self.dataManager = .preview
        self.payManager = PayManager(dataManager: .preview, settingsStore: settingsStore, calendar: .current)
        self.notificationService = NotificationService(center: .current())
    }
}
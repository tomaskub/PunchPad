//
//  ContainerProtocol.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 15/04/2024.
//

import Foundation

protocol ContainerProtocol {
    var dataManager: any DataManaging { get }
    var payManager: PayManager { get }
    var timerProvider: Timer.Type { get }
    var settingsStore: SettingsStore { get }
    var notificationService: NotificationService { get }
}

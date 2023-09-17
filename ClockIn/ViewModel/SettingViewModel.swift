//
//  SettingViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/3/23.
//

import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    
    private var dataManager: DataManager
    @Published var settingsStore: SettingsStore
    @Published var timerHours: Int
    @Published var timerMinutes: Int
    @Published var overtimeHours: Int
    @Published var overtimeMinutes: Int
    @Published var grossPayPerMonthText: String
    
    init(dataManger: DataManager, settingsStore: SettingsStore) {
        self.dataManager = dataManger
        self.settingsStore = settingsStore
        self.timerHours = settingsStore.workTimeInSeconds / 3600
        self.timerMinutes = (settingsStore.workTimeInSeconds % 3600) / 60
        self.overtimeHours = settingsStore.maximumOvertimeAllowedInSeconds / 3600
        self.overtimeMinutes = (settingsStore.maximumOvertimeAllowedInSeconds % 3600) / 60
        self.grossPayPerMonthText = String(settingsStore.grossPayPerMonth)
        setSubscribers()
    }
    private func setSubscribers() {
        
        settingsStore.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.objectWillChange.send()
                self.timerHours = settingsStore.workTimeInSeconds / 3600
                self.timerMinutes = (settingsStore.workTimeInSeconds % 3600) / 60
                self.overtimeHours = settingsStore.maximumOvertimeAllowedInSeconds / 3600
                self.overtimeMinutes = (settingsStore.maximumOvertimeAllowedInSeconds % 3600) / 60
                self.grossPayPerMonthText = String(settingsStore.grossPayPerMonth)
            }.store(in: &subscriptions)
        
        settingsStore.$isSendingNotification
            .filter({ $0 })
            .sink { [weak self] value in
                guard let self else { return }
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { success, error in
                    if let error = error {
                        print(error.localizedDescription)
                        self.settingsStore.isSendingNotification = false
                    }
                })
            }.store(in: &subscriptions)
        
        setWorkTimeSubscribers()
        setOvertimeSubscribers()
        setGrossPaySubscribers()
        
    }
    
    private func setGrossPaySubscribers() {
        $grossPayPerMonthText.sink { [weak self] value in
            guard let self else { return }
            let filtered = value.filter({"0123456789".contains($0)})
            if let newGross = Int(filtered) {
                self.settingsStore.grossPayPerMonth = newGross
            }
        }.store(in: &subscriptions)
                
    }
    
    private func setWorkTimeSubscribers() {
        $timerHours
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .combineLatest($timerMinutes.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main))
            .sink { [weak self] (hours, minutes) in
                guard let self else { return }
                let newWorkTime = self.calculateTimeInSeconds(hours: hours, minutes: minutes )
                if newWorkTime != self.settingsStore.workTimeInSeconds {
                    self.settingsStore.workTimeInSeconds = newWorkTime
                }
            }.store(in: &subscriptions)
        
        $timerMinutes
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .combineLatest($timerHours.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main))
            .sink { [weak self] (minutes, hours) in
            guard let self else { return }
                self.settingsStore.workTimeInSeconds = self.calculateTimeInSeconds(hours: hours, minutes: minutes)
            }.store(in: &subscriptions)
    }
    
    private func setOvertimeSubscribers() {
        $overtimeHours
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .combineLatest($overtimeMinutes.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main))
            .sink { [weak self] (hours, minutes) in
                guard let self else { return }
                self.settingsStore.maximumOvertimeAllowedInSeconds = self.calculateTimeInSeconds(hours: hours, minutes: minutes)
            }.store(in: &subscriptions)
        
        $overtimeMinutes
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .combineLatest($overtimeHours.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main))
            .sink { [weak self] (minutes, hours) in
                guard let self else { return }
                self.settingsStore.maximumOvertimeAllowedInSeconds =  self.calculateTimeInSeconds(hours: hours, minutes: minutes)
            }.store(in: &subscriptions)
    }
    
    private func calculateTimeInSeconds(hours: Int, minutes: Int) -> Int {
        return hours * 3600 + minutes * 60
    }
    func deleteAllData() {
        dataManager.deleteAll()
    }
    
    func resetUserDefaults() {
        SettingsStore.clearUserDefaults()
    }
}

//
//  CoreDataViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/31/23.
//

import Foundation
import CoreData
import Combine

class HistoryViewModel: ObservableObject {
    
    @Published private var dataManager: DataManager
    private var settingsStore: SettingsStore
    private var maximumOvertimeInSeconds: Int {
        settingsStore.maximumOvertimeAllowedInSeconds
    }
    private var scheduledWorkTimeInSeconds: Int {
        settingsStore.workTimeInSeconds
    }
    
    private var subscriptions: Set<AnyCancellable> = .init()
    
    init(dataManager: DataManager, settingsStore: SettingsStore) {
        self.dataManager = dataManager
        self.settingsStore = settingsStore
        dataManager.objectWillChange.sink(receiveValue: { [weak self] _ in
            self?.objectWillChange.send()
        }).store(in: &subscriptions)
    }
    
    var entries: [Entry] {
        dataManager.entryArray
    }
    
    /// provide a formatted string describing the amount of hours between start and finish date in an Entry object
    func timeWorkedLabel(for entry: Entry) -> String {
        
        let sumWorkedInSec = entry.workTimeInSeconds + entry.overTimeInSeconds
        let hours = sumWorkedInSec / 3600
        let minutes = (sumWorkedInSec % 3600) / 60
        
        let hoursString = hours > 9 ? "\(hours)" : "0\(hours)"
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        
        return "\(hoursString) hours \(minutesString) minutes"
    }
    
    ///Converts overtime value in seconds to a fraction of the current user maximum for overtime
    ///Value return is between 0 and 1
    ///If the maximum overtime value retrived is equal to 0, the return will be 1
    func convertOvertimeToFraction(entry: Entry) -> CGFloat {
        guard maximumOvertimeInSeconds != 0 else { return 1 }
        return CGFloat(entry.overTimeInSeconds) / CGFloat(maximumOvertimeInSeconds)
    }
    
    ///Converts work time value in seconds to a fraction of the current user normal workday
    ///Value returned is between 0 and 1
    ///If the maximum overtime value retrived is equal to 0, the return will be 1
    func convertWorkTimeToFraction(entry: Entry) -> CGFloat {
        guard scheduledWorkTimeInSeconds != 0 else { return 1 }
        return CGFloat(entry.workTimeInSeconds) / CGFloat(scheduledWorkTimeInSeconds)
    }
    
    func deleteEntry(entry: Entry) {
        dataManager.delete(entry: entry)
    }
    
    func updateAndSave(entry: Entry) {
        dataManager.updateAndSave(entry: entry)
    }
}
 

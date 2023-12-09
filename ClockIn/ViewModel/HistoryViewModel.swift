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
    @Published var paginationState: PaginationState = .idle
    @Published var isMoreEntriesAvaliable: Bool = true
    
    @Published var groupedEntries: [[Entry]] = []
    
    private var periodService: ChartPeriodService = .init(calendar: .current)
    private var sizeOfChunk: Int = 15
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
        self.$groupedEntries
            .map { [weak self] array in
                guard let self,
                      let lastEntry = array.last?.last else { return false }
                if let _ = self.dataManager.fetch(from: nil, 
                                                  to: lastEntry.startDate,
                                                  ascendingOrder: false,
                                                  fetchLimit: 1) {
                    return true
                } else {
                    return false
                }
            }.assign(to: &self.$isMoreEntriesAvaliable)
            
        self.groupedEntries = loadInitialEntries()
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

//MARK: POPULATE LIST DATA
extension HistoryViewModel {
    func loadInitialEntries() -> [[Entry]] {
        guard let entries = dataManager.fetch(from: nil, to: nil, fetchLimit: sizeOfChunk) else { return [[]] }
        return groupEntriesByYearMonth(entries)
    }
    
    func loadMoreItems() {
        paginationState = .isLoading
        
        guard let lastDateEntry = groupedEntries.last?.last else {
            paginationState = .error
            return
        }
        
        let currentStartDate = lastDateEntry.startDate
        guard let fetchedEntries = dataManager.fetch(from: nil, to: currentStartDate, fetchLimit: sizeOfChunk) else { return }
        var entryPool = groupedEntries.flatMap({ $0 })
        entryPool.append(contentsOf: fetchedEntries)
        groupedEntries = groupEntriesByYearMonth(entryPool)
        
        paginationState = .idle
    }
    
    private func groupEntriesByYearMonth(_ entries: [Entry]) -> [[Entry]] {
        var result: [[Entry]] = .init()
        
        var currentYearMonth: DateComponents?
        var currentEntries: [Entry] = .init()
        
        for entry in entries {
            let entryDateComponents = Calendar.current.dateComponents([.month,.year], from: entry.startDate)
            if entryDateComponents != currentYearMonth {
                if !currentEntries.isEmpty {
                    result.append(currentEntries)
                }
                currentEntries = [entry]
                currentYearMonth = entryDateComponents
            } else {
                currentEntries.append(entry)
            }
        }
        if !currentEntries.isEmpty {
            result.append(currentEntries)
        }
        return result
    }
}
 

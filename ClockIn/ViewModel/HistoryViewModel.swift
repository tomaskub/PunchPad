//
//  CoreDataViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/31/23.
//

import Foundation
import CoreData
import Combine

final class HistoryViewModel: ObservableObject {
    @Published private var dataManager: DataManager
    private var settingsStore: SettingsStore
    private var periodService: ChartPeriodService = .init(calendar: .current)
    private var sizeOfChunk: Int?
    private var subscriptions: Set<AnyCancellable> = .init()
    @Published var groupedEntries: [[Entry]] = []
    @Published var paginationState: PaginationState = .idle
    @Published var isMoreEntriesAvaliable: Bool = false
    @Published var filterFromDate: Date = Date()
    @Published var filterToDate: Date = Date()
    @Published var sortAscending: Bool = false
    @Published var isSortingActive: Bool = false
    
    init(dataManager: DataManager, settingsStore: SettingsStore, sizeOfChunk: Int? = 15) {
        self.dataManager = dataManager
        self.settingsStore = settingsStore
        self.sizeOfChunk = sizeOfChunk
        
        dataManager.objectWillChange.sink(receiveValue: { [weak self] value in
            guard let self else { return }
            if !self.isSortingActive {
                self.groupedEntries = self.loadInitialEntries()
            } else {
                self.applyFilters()
            }
        }).store(in: &subscriptions)
        
        self.$groupedEntries
            .filter({ [weak self] _ in
                guard let self else { return false }
                return !self.isSortingActive
            })
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
    
    func deleteEntry(entry: Entry) {
        dataManager.delete(entry: entry)
    }
    
    func updateAndSave(entry: Entry) {
        dataManager.updateAndSave(entry: entry)
    }
}

//MARK: POPULATE LIST DATA
extension HistoryViewModel {
    func resetFilters() {
        isSortingActive = false
        groupedEntries = loadInitialEntries()
    }
    
    func applyFilters() {
        isSortingActive = true
        let startDate = Calendar.current.startOfDay(for: filterFromDate)
        let finishDate = Calendar.current.startOfDay(for: filterToDate)
        guard let entries = dataManager.fetch(from: startDate,
                                              to: finishDate,
                                              ascendingOrder: sortAscending) else {
            groupedEntries = []
            return
        }
        groupedEntries = groupEntriesByYearMonth(entries)
    }
    
    func loadInitialEntries() -> [[Entry]] {
        guard let entries = dataManager.fetch(from: nil, to: nil, fetchLimit: sizeOfChunk) else { return [[]] }
        return groupEntriesByYearMonth(entries)
    }
    
    func loadMoreItems() {
        guard isSortingActive == false else { return }
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
 

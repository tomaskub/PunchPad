//
//  CoreDataViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/31/23.
//

import ChartPeriodService
import Combine
import CoreData
import DomainModels
import Foundation
import OSLog
import Persistance // TODO: Consider using persistance interfaces library approach?
import SettingsService

public final class HistoryViewModel: ObservableObject {
    private var logger = Logger.historyViewModel
    private var dataManager: any DataManaging
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
    
    public init(dataManager: any DataManaging, settingsStore: SettingsStore, sizeOfChunk: Int? = 15) {
        self.dataManager = dataManager
        self.settingsStore = settingsStore
        self.sizeOfChunk = sizeOfChunk
        
        dataManager.dataDidChange.sink(receiveValue: { [weak self] _ in
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
                      let lastEntry = array.last?.last,
                      self.dataManager.fetch(from: nil,
                                                        to: lastEntry.startDate,
                                                        ascendingOrder: false,
                                                        fetchLimit: 1) != nil
                else { return false }
                return true
            }.assign(to: &self.$isMoreEntriesAvaliable)
            
        self.groupedEntries = loadInitialEntries()
    }
    
    /// Return new entry with current date, empty time properties, and default values driven by setting store values
    public func newEntry() -> Entry {
        return Entry(startDate: Date(),
                          finishDate: Date(),
                          workTimeInSec: 0,
                          overTimeInSec: 0,
                          maximumOvertimeAllowedInSeconds: settingsStore.maximumOvertimeAllowedInSeconds,
                          standardWorktimeInSeconds: settingsStore.workTimeInSeconds,
                          grossPayPerMonth: settingsStore.grossPayPerMonth,
                          calculatedNetPay: nil)
    }
    
    func deleteEntry(entry: Entry) {
        dataManager.delete(entry: entry)
    }
    
    func updateAndSave(entry: Entry) {
        dataManager.updateAndSave(entry: entry)
    }
}

// MARK: POPULATE LIST DATA
extension HistoryViewModel {
    func resetFilters() {
        logger.debug("resetFilters called")
        isSortingActive = false
        groupedEntries = loadInitialEntries()
    }
    
    func applyFilters() {
        logger.debug("applyFilters called")
        isSortingActive = true
        let startDate = Calendar.current.startOfDay(for: filterFromDate)
        let finishDate = Calendar.current.startOfDay(for: filterToDate)
        guard let entries = dataManager.fetch(from: startDate,
                                              to: finishDate,
                                              ascendingOrder: sortAscending,
                                              fetchLimit: nil) else {
            groupedEntries = []
            return
        }
        groupedEntries = groupEntriesByYearMonth(entries)
    }
    
    func loadInitialEntries() -> [[Entry]] {
        logger.debug("loadInitialEntries called")
        guard let entries = dataManager.fetch(from: nil,
                                              to: nil,
                                              ascendingOrder: false,
                                              fetchLimit: sizeOfChunk) else { return [[]] }
        return groupEntriesByYearMonth(entries)
    }
    
    func loadMoreItems() {
        logger.debug("loadMoreItems called")
        guard isSortingActive == false else { return }
        paginationState = .isLoading
        
        guard let lastDateEntry = groupedEntries.last?.last else {
            paginationState = .error
            return
        }
        
        let currentStartDate = lastDateEntry.startDate
        guard let fetchedEntries = dataManager.fetch(from: nil,
                                                     to: currentStartDate,
                                                     ascendingOrder: false,
                                                     fetchLimit: sizeOfChunk) else { return }
        var entryPool = groupedEntries.flatMap({ $0 })
        entryPool.append(contentsOf: fetchedEntries)
        groupedEntries = groupEntriesByYearMonth(entryPool)
        
        paginationState = .idle
    }
    
    private func groupEntriesByYearMonth(_ entries: [Entry]) -> [[Entry]] {
        logger.debug("groupEntriesByYearMonth called")
        var result: [[Entry]] = .init()
        
        var currentYearMonth: DateComponents?
        var currentEntries: [Entry] = .init()
        
        for entry in entries {
            let entryDateComponents = Calendar.current.dateComponents([.month, .year], from: entry.startDate)
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
 

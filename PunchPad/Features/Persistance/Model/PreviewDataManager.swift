//
//  PreviewDataManager.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 05/05/2024.
//

import Foundation
import Combine
import OSLog

final class PreviewDataManager: NSObject, DataManaging {
    var dataDidChange = PassthroughSubject<Void, Never>()
    private var data = [Entry]()
    private let logger = Logger.dataManager
    
    init(with initialData: [Entry] = PreviewDataFactory.buildDataForPreviewForYear()) {
        super.init()
        logger.debug("Initializing sata manager")
        data = initialData
        dataDidChange.send()
    }
    
    func updateAndSave(entry: Entry) {
        logger.debug("updateAndSave called")
        data.append(entry)
        dataDidChange.send()
    }
    
    func delete(entry: Entry) {
        logger.debug("delete called")
        data.removeAll { $0.id == entry.id }
        dataDidChange.send()
    }
    
    func deleteAll() {
        logger.debug("deleteAll called")
        data = .init()
        dataDidChange.send()
    }
    
    func fetch(forDate date: Date) -> Entry? {
        logger.debug("fetchForDate called")
        return data.first { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
    }
    
    func fetch(for period: Period) -> [Entry]? {
        logger.debug("fetchForPeriod called")
        return fetch(from: period.0, to: period.1)
    }
    
    func fetch(from startDate: Date?,
               to finishDate: Date?,
               ascendingOrder: Bool = false,
               fetchLimit: Int? = nil) -> [Entry]? {
        logger.debug("fetch called")
        var result = data.filter { data in
            if let startDate, let finishDate {
                return data.finishDate > startDate && data.finishDate < finishDate
            } else if let startDate {
                return data.finishDate > startDate
            } else if let finishDate {
                return data.finishDate < finishDate
            }
            return true
        }
        
        if ascendingOrder {
            result.sort(by: { $0.finishDate < $1.finishDate })
        } else {
            result.sort(by: { $0.finishDate > $1.finishDate})
        }
        
        if let fetchLimit, result.count > fetchLimit {
            return result.dropLast(result.count - fetchLimit)
        }
        
        return result
    }
    
    func fetchOldestExisting() -> Entry? {
        logger.debug("fetchOldest called")
        return data.min { $0.startDate < $1.startDate }
    }
    
    func fetchNewestExisting() -> Entry? {
        logger.debug("fetchNewest called")
        return data.max { $0.startDate > $1.startDate }
    }
}

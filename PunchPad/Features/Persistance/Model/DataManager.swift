//
//  DataManager.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/2/23.
//

import Foundation
import Combine
import CoreData
import OSLog

final class DataManager: NSObject {
    let dataDidChange = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger.dataManager
    fileprivate var managedObjectContext: NSManagedObjectContext
    
    init(with persistanceController: PersistanceController = PersistanceController(inMemory: false)) {
        logger.debug("Initializing data manager")
        self.managedObjectContext = persistanceController.viewContext
        super.init()
        // Notify of change anytime CD changes
        NotificationCenter.default.publisher(for: Notification.Name.NSManagedObjectContextDidSave)
            .sink { [weak self] _ in
                self?.dataDidChange.send()
            }
            .store(in: &cancellables)
    }
}

extension DataManager: DataManaging {
    /// Updates and saves an entry to entryMO, if there is no entryMO it will create a corresponding entryMO
    func updateAndSave(entry: Entry) {
        logger.debug("updateAndSave called")
        let predicate = NSPredicate(format: "id = %@", entry.id as CVarArg)
        let result = fetchFirst(EntryMO.self, predicate: predicate)
        switch result {
        case .success(let managedObject):
            if let entryMO = managedObject {
                // update
                update(entryMO: entryMO, from: entry)
            } else {
                // create entryMO from entry
                entryMO(from: entry)
            }
        case .failure(let error):
            logger.error("Could not fetch Entry to save - \(error): \(error.localizedDescription)")
        }
        
        saveContext()
    }
    
    func delete(entry: Entry) {
        logger.debug("delete called")
        let predicate = NSPredicate(format: "id = %@", entry.id as CVarArg)
        let result = fetchFirst(EntryMO.self, predicate: predicate)
        switch result {
        case .success(let managedObject):
            if let entryMO = managedObject {
                logger.debug("Deleting found entry")
                managedObjectContext.delete(entryMO)
            }
        case .failure(let failure):
            logger.error("Could not fetch entry to delete - \(failure): \(failure.localizedDescription)")
        }
        saveContext()
    }
    
    func deleteAll() {
        logger.debug("deleteAll called")
        let request: NSFetchRequest<EntryMO> = EntryMO.fetchRequest()
        do {
            let result = try managedObjectContext.fetch(request)
            for entryMO in result {
                managedObjectContext.delete(entryMO)
            }
            saveContext()
        } catch let error {
            logger.error("Delete all function failed to delete all objects - \(error): \(error.localizedDescription)")
        }
    }
    
    func fetch(forDate date: Date) -> Entry? {
        logger.debug("Fetch called for date: \(date)")
        let startDate = Calendar.current.startOfDay(for: date)
        guard let finishDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) else {
            logger.error("Could not build a date for the end of the day, returning nil")
            return nil }
        let startPredicate = NSPredicate(format: "finishDate > %@", startDate as CVarArg)
        let finishPredicate = NSPredicate(format: "finishDate < %@", finishDate as CVarArg)
        let compPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startPredicate, finishPredicate])
        
        let result = fetchFirst(EntryMO.self, predicate: compPredicate)
        
        switch result {
        case .success(let resultObject):
            if let entryMO = resultObject {
                logger.debug("Retrieved entry successfully")
                return Entry(entryMO: entryMO)
            } else {
                logger.debug("Retrieved object that was not EntryMo")
                return nil
            }
        case .failure(let error):
            logger.error("Could not fech any entries for given date - \(error): \(error.localizedDescription)")
            return nil
        }
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
        let request: NSFetchRequest<EntryMO> = EntryMO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: ascendingOrder)]
        var subpredicates = [NSPredicate]()
        
        if let startDate {
            let startPredicate = NSPredicate(format: "finishDate > %@", startDate as CVarArg)
            subpredicates.append(startPredicate)
        }
        if let finishDate {
            let finishPredicate = NSPredicate(format: "finishDate < %@", finishDate as CVarArg)
            subpredicates.append(finishPredicate)
        }
        if let fetchLimit {
            request.fetchLimit = fetchLimit
        }
        
        let compPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        request.predicate = compPredicate
        logger.debug("Predicate to fetch: \(compPredicate.description)")
        
        do {
            let result = try managedObjectContext.fetch(request)
            logger.debug("Fetched successfully \(result.count) objects")
            return result.map({ Entry(entryMO: $0) })
        } catch let error {
            logger.error("Could not fetch with predicate - \(error): \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchOldestExisting() -> Entry? {
        logger.debug("fetchOldestExisting called")
        let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: true)
        let result = fetchFirst(EntryMO.self, predicate: nil, sortDescriptors: [sortDescriptor])
        switch result {
        case .success(let success):
            if let entryMO = success {
                return Entry(entryMO: entryMO)
            } else {
                return nil
            }
        case .failure(let error):
            logger.error("Could not fetch entry - \(error): \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchNewestExisting() -> Entry? {
        logger.debug("fetchNewestExisting called")
        let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: false)
        let result = fetchFirst(EntryMO.self, predicate: nil, sortDescriptors: [sortDescriptor])
        switch result {
        case .success(let success):
            if let entryMO = success {
                return Entry(entryMO: entryMO)
            } else {
                return nil
            }
        case .failure(let error):
            logger.error("Could not fetch entry - \(error): \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Core Data Helper Functions
private extension DataManager {
    func saveContext() {
        logger.debug("saveContext called")
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error {
                logger.error("Error saving - \(error): \(error.localizedDescription)")
            }
        }
    }
    
    func fetchFirst<T: NSManagedObject>(_ objectType: T.Type,
                                        predicate: NSPredicate?,
                                        sortDescriptors: [NSSortDescriptor]? = nil) -> Result<T?, Error> {
        logger.debug("fetchFirst called")
        let request = objectType.fetchRequest()
        request.predicate = predicate
        request.fetchLimit = 1
        request.sortDescriptors = sortDescriptors
        do {
            let result = try managedObjectContext.fetch(request) as? [T]
            return .success(result?.first)
        } catch {
            return .failure(error)
        }
    }
    
    func entryMO(from entry: Entry) {
        logger.debug("entryMO called")
        let entryMO = EntryMO(context: managedObjectContext)
        entryMO.id = entry.id
        update(entryMO: entryMO, from: entry)
    }
    
    func update(entryMO: EntryMO, from entry: Entry) {
        logger.debug("updateEntryMo called")
        entryMO.startDate = entry.startDate
        entryMO.finishDate = entry.finishDate
        entryMO.workTime = Int64(entry.workTimeInSeconds)
        entryMO.overTime = Int64(entry.overTimeInSeconds)
        entryMO.maximumOvertimeAllowedInSeconds = Int64(entry.maximumOvertimeAllowedInSeconds)
        entryMO.standardWorktimeInSeconds = Int64(entry.standardWorktimeInSeconds)
        entryMO.grossPayPerMonth = Int64(entry.grossPayPerMonth)
        if let netPay = entry.calculatedNetPay {
            entryMO.calculatedNetPay = Double(netPay)
        }
    }
}

// MARK: - Entry Conv Init
extension Entry {
    fileprivate init(entryMO: EntryMO) {
        self.id = entryMO.id
        self.startDate = entryMO.startDate
        self.finishDate = entryMO.finishDate
        self.workTimeInSeconds = Int(entryMO.workTime)
        self.overTimeInSeconds = Int(entryMO.overTime)
        self.maximumOvertimeAllowedInSeconds = Int(entryMO.maximumOvertimeAllowedInSeconds)
        self.standardWorktimeInSeconds = Int(entryMO.standardWorktimeInSeconds)
        self.grossPayPerMonth = Int(entryMO.grossPayPerMonth)
        self.calculatedNetPay = Double(entryMO.calculatedNetPay)
    }
}

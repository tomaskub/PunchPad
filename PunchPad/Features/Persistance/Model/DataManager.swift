//
//  DataManager.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/2/23.
//

import Foundation
import Combine
import CoreData

enum DataManagerType {
    case normal, preview, testing
}

final class DataManager: NSObject, DataManaging {
    
    //MARK: STATIC INSTANCES
    static let shared = DataManager(type: .normal)
    static let preview = DataManager(type: .preview)
    static let testing = DataManager(type: .testing)
    private var cancellables = Set<AnyCancellable>()
    fileprivate var managedObjectContext: NSManagedObjectContext
    
    //MARK: INIT
    private init(type: DataManagerType) {
        switch type {
        case .normal:
            let persistanceController = PersistanceController()
            self.managedObjectContext = persistanceController.viewContext
        case .preview:
            let persistanceController = PersistanceController(inMemory: true)
            self.managedObjectContext = persistanceController.viewContext
        case .testing:
            let persistanceController = PersistanceController(inMemory: true)
            self.managedObjectContext = persistanceController.viewContext
        }
        super.init()
        
        //Notify of change anytime CD changes
        NotificationCenter.default.publisher(for: Notification.Name.NSManagedObjectContextDidSave)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        switch type {
        case .normal:
            break
        case .preview:
            addPreviewDataFromFactory()
        case .testing:
            addTestingData()
        }
    }
    
    //MARK: HELPER METHODS
    ///Checks for changes in the managed object context and saves if uncommited changes are present
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error {
                print("Error saving: \(error) - \(error.localizedDescription)")
            }
        }
    }
    ///conv fetch returning the first element or an error if the fetch failed
    private func fetchFirst<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]? = nil) -> Result<T?, Error> {
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
    
    private func addPreviewDataFromFactory() {
        let entryToAdd = PreviewDataFactory.buildDataForPreviewForYear()
        for entry in entryToAdd {
            self.updateAndSave(entry: entry)
        }
    }
    
    private func addTestingData() {
        var dateComponents = Calendar.current.dateComponents([.month,.year], from: Date())
        dateComponents.day = 1
        let date = Calendar.current.date(from: dateComponents)!
        let entry = EntryMO(context: managedObjectContext)
        entry.id = UUID()
        entry.startDate = Calendar.current.date(byAdding: .hour, value: 6, to: date)!
        entry.finishDate = Calendar.current.date(byAdding: DateComponents(hour: 14, minute: 30), to: date)!
        entry.overTime = Int64(1 * 1800)
        entry.workTime = 8 * 3600
        entry.maximumOvertimeAllowedInSeconds = 5 * 3600
        entry.standardWorktimeInSeconds = 8 * 3600
        entry.grossPayPerMonth = 10000
        saveContext()
    }
}

//MARK: ENTRY METHODS
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

extension DataManager {
    ///Updates and saves an entry to entryMO, if there is no entryMO it will create a corresponding entryMO
    func updateAndSave(entry: Entry) {
        let predicate = NSPredicate(format: "id = %@", entry.id as CVarArg)
        let result = fetchFirst(EntryMO.self, predicate: predicate)
        switch result {
        case .success(let managedObject):
            if let entryMO = managedObject {
                //update
                update(entryMO: entryMO, from: entry)
            } else {
                // create entryMO from entry
                entryMO(from: entry)
            }
        case .failure(let error):
            print("Could not fetch Entry to save - \(error): \(error.localizedDescription)")
        }
        
        saveContext()
        
    }
    //Add documentation and handle failure better?
    func delete(entry: Entry) {
        let predicate = NSPredicate(format: "id = %@", entry.id as CVarArg)
        let result = fetchFirst(EntryMO.self, predicate: predicate)
        switch result {
        case .success(let managedObject):
            if let entryMO = managedObject {
                managedObjectContext.delete(entryMO)
            }
        case .failure(let failure):
            print("Could not fetch entry to delete: \(failure.localizedDescription)")
        }
        saveContext()
    }
    
    func deleteAll() {
        let request: NSFetchRequest<EntryMO> = EntryMO.fetchRequest()
        do {
            let result = try managedObjectContext.fetch(request)
            for entryMO in result {
                managedObjectContext.delete(entryMO)
            }
            saveContext()
        } catch let error {
            print("Delete all function failed to delete all objects - \(error):\(error.localizedDescription)")
        }
    }
    
    func fetch(forDate date: Date) -> Entry? {
        let startDate = Calendar.current.startOfDay(for: date)
        guard let finishDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) else {
            print("Could not build a date for the end of the day")
            return nil }
        let startPredicate = NSPredicate(format: "finishDate > %@", startDate as CVarArg)
        let finishPredicate = NSPredicate(format: "finishDate < %@", finishDate as CVarArg)
        let compPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startPredicate, finishPredicate])
        
        let result = fetchFirst(EntryMO.self, predicate: compPredicate)
        
        switch result {
        case .success(let resultObject):
            if let entryMO = resultObject {
                return Entry(entryMO: entryMO)
            } else {
                return nil
            }
        case .failure(let error):
            print("Could not fech any entries for given date - \(error): \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetch(for period: Period) -> [Entry]? {
        return fetch(from: period.0, to: period.1)
    }
    
    func fetch(from startDate: Date?, 
               to finishDate: Date?,
               ascendingOrder: Bool = false,
               fetchLimit: Int? = nil) -> [Entry]? {
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
        
        do {
            let result = try managedObjectContext.fetch(request)
            return result.map({ Entry(entryMO: $0) })
        } catch {
            return nil
        }
    }
    
    func fetchOldestExisting() -> Entry? {
        let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: true)
        let result = fetchFirst(EntryMO.self, predicate: nil, sortDescriptors: [sortDescriptor])
        switch result {
        case .success(let success):
            if let entryMO = success {
                return Entry(entryMO: entryMO)
            } else {
                return nil
            }
        case .failure(_):
            return nil
        }
    }
    
    func fetchNewestExisting() -> Entry? {
        let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: false)
        let result = fetchFirst(EntryMO.self, predicate: nil, sortDescriptors: [sortDescriptor])
        switch result {
        case .success(let success):
            if let entryMO = success {
                return Entry(entryMO: entryMO)
            } else {
                return nil
            }
        case .failure(_):
            return nil
        }
    }
    
    private func entryMO(from entry: Entry) {
        let entryMO = EntryMO(context: managedObjectContext)
        entryMO.id = entry.id
        update(entryMO: entryMO, from: entry)
    }
    
    private func update(entryMO: EntryMO, from entry: Entry) {
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

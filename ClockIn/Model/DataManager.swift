//
//  DataManager.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/2/23.
//

import Foundation
import CoreData

enum DataManagerType {
case normal, preview, testing
}

class DataManager: NSObject, ObservableObject {
    
    //MARK: STATIC INSTANCES
    static let shared = DataManager(type: .normal)
    static let preview = DataManager(type: .preview)
    static let testing = DataManager(type: .testing)
    
    //MARK: PUBLISHED PROPERTIES
    @Published var entryArray = [Entry]()
    @Published var entryThisMonth = [Entry]()
    
    //MARK: PRIVATE PROPERTIES
    fileprivate var managedObjectContext: NSManagedObjectContext
    private let entryFetchResultsController: NSFetchedResultsController<EntryMO>
    private let entryThisMonthFetchResultsController: NSFetchedResultsController<EntryMO>
    
    //MARK: INIT
    private init(type: DataManagerType) {
        
        switch type {
        
        case .normal:
            let persistanceController = PersistanceController()
            self.managedObjectContext = persistanceController.viewContext
        
        case .preview:
            let persistanceController = PersistanceController(inMemory: true)
            self.managedObjectContext = persistanceController.viewContext
            //add data to preview
            for i in 1...5 {
                let date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -i, to: Date())!)
                let entry = EntryMO(context: managedObjectContext)
                entry.id = UUID()
                entry.startDate = Calendar.current.date(byAdding: .hour, value: 8, to: date)!
                entry.finishDate = Calendar.current.date(byAdding: .hour, value: 16+i, to: date)!
                entry.overTime = Int64(i * 1800)
                entry.workTime = 8 * 3600
            }
            //save added data
            try? self.managedObjectContext.save()
        
        case .testing:
            let persistanceController = PersistanceController(inMemory: true)
            self.managedObjectContext = persistanceController.viewContext
        }
        
        //Build FRCs
        let fetchRequest: NSFetchRequest<EntryMO> = EntryMO.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        entryFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                 managedObjectContext: managedObjectContext,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        
        let fetchRequestThisMonth: NSFetchRequest<EntryMO> = EntryMO.fetchRequest()
        fetchRequestThisMonth.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        let dateComponents = Calendar.current.dateComponents([.month,.year], from: Date())
        let startDate = Calendar.current.date(from: dateComponents)!
        let finishDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
            
        let startPredicate = NSPredicate(format: "finishDate > %@", startDate as CVarArg)
        let finishPredicate = NSPredicate(format: "finishDate < %@", finishDate as CVarArg)
        let compPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startPredicate, finishPredicate])
        fetchRequestThisMonth.predicate = compPredicate
        
        entryThisMonthFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequestThisMonth,
                                                                          managedObjectContext: managedObjectContext,
                                                                          sectionNameKeyPath: nil,
                                                                          cacheName: nil)
        
        
        super.init() // this is super from NSObject?? - need to check
        
        entryFetchResultsController.delegate = self
        entryThisMonthFetchResultsController.delegate = self
        
        try? entryFetchResultsController.performFetch()
        if let newEntries = entryFetchResultsController.fetchedObjects {
            self.entryArray = newEntries.map({
                Entry(entryMO: $0)
            })
        }
        
        try? entryThisMonthFetchResultsController.performFetch()
        if let newEntries = entryThisMonthFetchResultsController.fetchedObjects {
            self.entryThisMonth = newEntries.map({ Entry(entryMO: $0)})
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
    private func fetchFirst<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate?) -> Result<T?, Error> {
        let request = objectType.fetchRequest()
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try managedObjectContext.fetch(request) as? [T]
            return .success(result?.first)
        } catch {
            return .failure(error)
        }
    }
}
extension DataManager: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetchedObjects = controller.fetchedObjects else { return }
        let newEntries = fetchedObjects.compactMap({$0 as? EntryMO})
        self.entryArray = newEntries.map { Entry(entryMO: $0) }
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
    }
    //may be obsoleted due to NSFRC
    func fetchWorkHistory() {
        let request: NSFetchRequest<EntryMO> = EntryMO.fetchRequest()
        do {
            let entryMO = try managedObjectContext.fetch(request)
            entryArray = entryMO.map({ entryMO in
                Entry(entryMO: entryMO)
            })
        } catch let error {
            print("Error fetching: \(error.localizedDescription)")
        }
    }
}

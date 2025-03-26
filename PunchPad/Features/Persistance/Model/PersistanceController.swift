//
//  PersistanceController.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/1/23.
//

import Foundation
import CoreData
import OSLog

// INFO: Potentially change to a class to help with passing logger into load peristent stores
// need to evaluate the impact of the changes - peristance controller should only be handled by data manager
struct PersistanceController {
    private static let name = "WorkHistory"
    private let logger = Logger.persistanceContainer
    private let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    init(inMemory: Bool = false) {
        logger.debug("Initializing persistance controller \(inMemory ? "in memory" : "in storage")")
        container = NSPersistentContainer(name: PersistanceController.name)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                #warning("TODO: implement error handling before shipping")
                fatalError("Fatal error: \(error), \(error.userInfo)")
            }
        })
    }
}

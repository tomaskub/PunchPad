//
//  PersistanceController.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/1/23.
//

import Foundation
import CoreData

struct PersistanceController {

    private let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WorkHistory")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                //Implement error handling - below is not appropriate to use in shiped code
                fatalError("Fatal error: \(error), \(error.userInfo)")
            }
        })
    }
}

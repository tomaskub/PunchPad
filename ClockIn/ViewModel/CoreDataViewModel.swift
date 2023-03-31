//
//  CoreDataViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/31/23.
//

import Foundation
import CoreData

class CoreDataViewModel: ObservableObject {
    let container: NSPersistentContainer
    
    init() {
        self.container = NSPersistentContainer(name: "WorkHistory")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error loading core data: \(error.localizedDescription)")
            } else {
                print("Set up core data successfuly")
            }
        }
    }
}

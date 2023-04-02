//
//  CoreDataViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/31/23.
//

import Foundation
import CoreData


class HistoryViewModel: ObservableObject {
    
    //    let container: NSPersistentContainer
//    private let context = PersistanceController.shared.viewContext
    
//    @Published var savedEntries: [Entry] = []
    @Published private var dataManager: DataManager
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
    }
    
    var entries: [Entry] {
        dataManager.entryArray
    }
    
}

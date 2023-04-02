//
//  CoreDataViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/31/23.
//

import Foundation
import CoreData


class WorkViewModel: ObservableObject {
    
    //    let container: NSPersistentContainer
    private let context = PersistanceController.shared.viewContext
    
    @Published var savedEntries: [Work] = []
    
    init() {
        //Removed and implemented in PersistanceController
        /*
         self.container = NSPersistentContainer(name: "WorkHistory")
         container.loadPersistentStores { (description, error) in
         if let error = error {
         print("Error loading core data: \(error.localizedDescription)")
         } else {
         print("Set up core data successfuly")
         }
         }
         */
        fetchWorkHistory()
    }
    
    func fetchWorkHistory() {
        let request: NSFetchRequest<Work> = Work.fetchRequest()
        do {
            savedEntries = try context.fetch(request)
        } catch let error {
            print("Error fetching: \(error.localizedDescription)")
        }
    }
    
    func addWork(startDate: Date, endDate: Date, overtime: Double) {
        let newWork = Work(context: context)
        
        newWork.startDate = startDate
        newWork.finishDate = endDate
        newWork.overTime = overtime
        newWork.workTime = 8
        
        saveData()
        
    }
    //This does not work now since shared instance is removed
    func saveData() {
//        PersistanceController.shared.saveContext()
        fetchWorkHistory()
    }
    
    func deleteData() {
        fetchWorkHistory()
        for entry in savedEntries {
            context.delete(entry)
        }
        saveData()
    }
    
    //this should be obsoleted
    func addFakeData() {
        
        for i in 1...5 {
            
            let date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -i, to: Date())!)
            addWork(
                startDate: Calendar.current.date(byAdding: .hour, value: 8, to: date)!,
                endDate: Calendar.current.date(byAdding: .hour, value: 16+i, to: date)!,
                overtime: Double(i))
        }
    }
}

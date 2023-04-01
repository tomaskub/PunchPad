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
    
    @Published var savedEntries: [Work] = []
    
    init() {
        self.container = NSPersistentContainer(name: "WorkHistory")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error loading core data: \(error.localizedDescription)")
            } else {
                print("Set up core data successfuly")
            }
        }
        fetchWorkHistory() 
    }
    
    func fetchWorkHistory() {
        let request: NSFetchRequest<Work> = Work.fetchRequest()
        do {
            savedEntries = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching: \(error.localizedDescription)")
        }
    }
    
    func addWork(startDate: Date, endDate: Date, overtime: Double) {
        
        let newWork = Work(context: container.viewContext)
        
        newWork.startDate = startDate
        newWork.finishDate = endDate
        newWork.overTime = overtime
        saveData()
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchWorkHistory()
        } catch let error {
            print("Error fetching: \(error.localizedDescription)")
        }
    }
    func deleteData() {
        fetchWorkHistory()
        for entry in savedEntries {
            container.viewContext.delete(entry)
        }
        saveData() 
    }
    
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

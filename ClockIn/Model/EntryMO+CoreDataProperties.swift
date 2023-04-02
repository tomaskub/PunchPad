//
//  EntryMO+CoreDataProperties.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/2/23.
//
//

import Foundation
import CoreData


extension EntryMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntryMO> {
        return NSFetchRequest<EntryMO>(entityName: "EntryMO")
    }

    @NSManaged public var finishDate: Date
    @NSManaged public var overTime: Double
    @NSManaged public var startDate: Date
    @NSManaged public var workTime: Double
    @NSManaged public var id: UUID

}

extension EntryMO : Identifiable {

}

//
//  Work+CoreDataProperties.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/31/23.
//
//

import Foundation
import CoreData


extension Work {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Work> {
        return NSFetchRequest<Work>(entityName: "Work")
    }

    @NSManaged public var finishDate: Date
    @NSManaged public var startDate: Date
    @NSManaged public var workTime: Double
    @NSManaged public var overTime: Double
}

extension Work : Identifiable {

}

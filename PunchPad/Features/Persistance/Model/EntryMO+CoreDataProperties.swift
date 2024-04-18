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
    @NSManaged public var overTime: Int64
    @NSManaged public var startDate: Date
    @NSManaged public var workTime: Int64
    @NSManaged public var id: UUID
    @NSManaged public var maximumOvertimeAllowedInSeconds: Int64
    @NSManaged public var standardWorktimeInSeconds: Int64
    @NSManaged public var grossPayPerMonth: Int64
    @NSManaged public var calculatedNetPay: Double
}

extension EntryMO : Identifiable {

}

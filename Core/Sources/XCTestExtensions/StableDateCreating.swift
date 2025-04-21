//
//  StableDateCreating.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 22/03/2025.
//
import Foundation

public protocol StableDateCreating {
    var fixedCalendar: Calendar { get }
    func createDate(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date?
}

//
//  TimerStoring.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 16/05/2024.
//

import DomainModels
import Foundation

protocol TimerStoring {
    func retrieve() throws -> TimerModel
    func save(_: TimerModel) throws
    func delete()
}

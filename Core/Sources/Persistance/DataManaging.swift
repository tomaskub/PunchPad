//
//  DataManaging.swift
//  
//
//  Created by Tomasz Kubiak on 04/05/2024.
//

import Foundation
import Combine
import DomainModels

public protocol DataManaging: AnyObject {
    var dataDidChange: PassthroughSubject<Void, Never> { get }
    func updateAndSave(entry: Entry)
    func delete(entry: Entry)
    func deleteAll()
    func fetch(forDate: Date) -> Entry?
    func fetch(for: Period) -> [Entry]?
    func fetch(from: Date?, to: Date?, ascendingOrder: Bool, fetchLimit: Int?) -> [Entry]?
    func fetchOldestExisting() -> Entry?
    func fetchNewestExisting() -> Entry?
}

//
//  CaseIterable+Extension.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 24/09/2023.
//

import Foundation

public extension CaseIterable where Self: Equatable {
    /// Return next enum case or the first one in case given case was last
    func next() -> Self {
        let all = Self.allCases
        let index = all.firstIndex(of: self)!
        let next = all.index(after: index)
        return all[next == all.endIndex ? all.startIndex : next]
    }
    
    /// Return previous enum case or the last one in case given case was first
    func previous() -> Self {
        let all = Self.allCases.reversed()
        let index = all.firstIndex(of: self)!
        let next = all.index(after: index)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}

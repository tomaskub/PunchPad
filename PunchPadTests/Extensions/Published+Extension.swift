//
//  Published+Extension.swift
//  PunchPadTests
//
//  Created by Tomasz Kubiak on 12/02/2024.
//

import Combine

extension Published.Publisher {
    /// Ignore initial value and collect N number of next values for a given published property
    /// - Parameter count: number of values to collect
    /// - Returns: type erased publisher emitng a single  array of collected output
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Never> {
        self.dropFirst()
            .collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}

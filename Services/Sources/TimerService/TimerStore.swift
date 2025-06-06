//
//  TimerStore.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 15/05/2024.
//

import DomainModels
import Foundation
import FoundationExtensions
import OSLog
import TimerServiceInterfaces

public struct TimerStore: TimerStoring {
    private let logger = Logger.timerStore
    private let storageKey = "timerModel"
    private let defaults: UserDefaults
    
    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    public func retrieve() throws -> TimerModel {
        logger.debug("retrieve called")
        let decoder = JSONDecoder()
        let data = defaults.data(forKey: storageKey)
        if let data {
            logger.debug("Data retrieved from defaults")
            let model = try decoder.decode(TimerModel.self, from: data)
            logger.debug("Data decoded to timer model")
            return model
        } else {
            logger.warning("Data failed to retrieve from defaults")
            throw TimerStoreError.failedToRetrieveData
        }
    }
    
    public func save(_ timerModel: TimerModel) throws {
        logger.debug("save called")
        let encoder = JSONEncoder()
        let data = try encoder.encode(timerModel)
        defaults.set(data, forKey: storageKey)
        logger.debug("Data saved in defaults")
    }
    
    public func delete() {
        logger.debug("delete called")
        defaults.removeObject(forKey: storageKey)
    }
}

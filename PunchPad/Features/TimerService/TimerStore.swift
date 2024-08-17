//
//  TimerStore.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 15/05/2024.
//

import Foundation

struct TimerStore: TimerStoring {
    let storageKey = "timerModel"
    let defaults: UserDefaults
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    func retrieve() throws -> TimerModel {
        let decoder = JSONDecoder()
        let data = defaults.data(forKey: storageKey)
        if let data {
            let model = try decoder.decode(TimerModel.self, from: data)
            return model
        } else {
            throw TimerStoreError.failedToRetrieveData
        }
    }
    
    func save(_ timerModel: TimerModel) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(timerModel)
        defaults.set(data, forKey: storageKey)
    }
    
    func delete() {
        defaults.removeObject(forKey: storageKey)
    }
}

//
//  MockTimer.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/12/23.
//

import Foundation

class MockTimer: Timer {
    
    var block: ((Timer) -> Void)!
    
    static var currentTimer: MockTimer!
    
    override func fire() {
        block(self)
    }
    
    override open class func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        
        let mockTimer = MockTimer()
        
        mockTimer.block = block
        
        MockTimer.currentTimer = mockTimer
        
        return mockTimer
    }
}

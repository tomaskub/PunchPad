//
//  MockTimer.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/12/23.
//

import Foundation

class MockTimer: Timer {
    
    var block: ((Timer) -> Void)!
    var isMockTimerValid = true
    
    static var currentTimer: MockTimer!
    
    override var isValid: Bool {
        return isMockTimerValid
    }
    
    override func fire() {
        if self.isValid {
            block(self)
        }
    }
    
    override open class func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        
        let mockTimer = MockTimer()
        mockTimer.isMockTimerValid = true
        
        mockTimer.block = block
        
        MockTimer.currentTimer = mockTimer
        
        return mockTimer
    }
    
    override func invalidate() {
        MockTimer.currentTimer.isMockTimerValid = false
    }
}

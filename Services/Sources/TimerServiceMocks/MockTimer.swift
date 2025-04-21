//
//  MockTimer.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 4/12/23.
//

import Foundation

public class MockTimer: Timer {
    
    public var block: ((Timer) -> Void)!
    public var isMockTimerValid = true
    
    public static var currentTimer: MockTimer!
    
    public override var isValid: Bool {
        return isMockTimerValid
    }
    
    public override func fire() {
        if self.isValid {
            block(self)
        }
    }
    
    public override class func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        
        let mockTimer = MockTimer()
        mockTimer.isMockTimerValid = true
        
        mockTimer.block = block
        
        MockTimer.currentTimer = mockTimer
        
        return mockTimer
    }
    
    public override func invalidate() {
        MockTimer.currentTimer.isMockTimerValid = false
    }
}

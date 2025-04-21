import DomainModels
import TimerServiceInterfaces

public class MockTimerStore: TimerStoring {
    public private(set) var retrieveCalled = false
    public private(set) var saveCalled = false
    public private(set) var deleteCalled = false
    public private(set) var shouldThrowOnSave = false
    public var modelToReturn: TimerModel?
    
    public init() {}
    
    public func retrieve() throws -> TimerModel {
        retrieveCalled = true
        guard let modelToReturn else {
            throw MockTimerStoreError.mock
        }
        return modelToReturn
    }
    
    public func save(_: TimerModel) throws {
        saveCalled = true
        if shouldThrowOnSave {
            throw MockTimerStoreError.mock
        }
    }
    
    public func delete() {
        deleteCalled = true
    }
}

public enum MockTimerStoreError: Error {
    case mock
}

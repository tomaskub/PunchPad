import ChartPeriodServiceInterfaces
import DomainModels
import Foundation

public final class MockChartPeriodService: ChartPeriodServicing {
    public private(set) var generatePeriodForInCalled: Bool = false
    public private(set) var generatePeriodFromToCalled: Bool = false
    public private(set) var retardPeriodCalled: Bool = false
    public private(set) var advancePeriodCalled: Bool = false
    public private(set) var returnPeriodMidDateCalled: Bool = false

    public var shouldThrowOnGeneratePeriodForIn: ChartPeriodServiceError?
    public var shouldThrowOnGeneratePeriodFromTo: ChartPeriodServiceError?
    public var shouldThrowOnRetardPeriod: ChartPeriodServiceError?
    public var shouldThrowOnAdvancePeriod: ChartPeriodServiceError?
    public var shouldThrowOnReturnPeriodMidDate: ChartPeriodServiceError?
    
    public var returnForGeneratePeriodForIn: Period?
    public var returnForGeneratePeriodFromTo: Period?
    public var returnForRetardPeriod: Period?
    public var returnForAdvancePeriod: Period?
    public var returnForReturnPeriodMidDate: Date?

    public func generatePeriod(for: Date, in: ChartTimeRange) throws -> Period {
        generatePeriodForInCalled = true
        if let shouldThrowOnGeneratePeriodForIn {
            throw shouldThrowOnGeneratePeriodForIn
        }
        if let returnForGeneratePeriodForIn {
            return returnForGeneratePeriodForIn
        } else {
            throw MockChartPeriodServiceError.didNotSetReturn
        }
    }
    
    public func generatePeriod(from: Entry, to: Entry) throws -> Period {
        generatePeriodFromToCalled = true
        if let shouldThrowOnGeneratePeriodFromTo {
            throw shouldThrowOnGeneratePeriodFromTo
        }
        if let returnForGeneratePeriodFromTo {
            return returnForGeneratePeriodFromTo
        } else {
            throw MockChartPeriodServiceError.didNotSetReturn
        }
    }
    
    public func retardPeriod(by: ChartTimeRange, from: Period) throws -> Period {
        retardPeriodCalled = true
        if let shouldThrowOnRetardPeriod {
            throw shouldThrowOnRetardPeriod
        }
        if let returnForRetardPeriod {
            return returnForRetardPeriod
        } else {
            throw MockChartPeriodServiceError.didNotSetReturn
        }
    }
    
    public func advancePeriod(by: ChartTimeRange, from: Period) throws -> Period {
        advancePeriodCalled = true
        if let shouldThrowOnAdvancePeriod {
            throw shouldThrowOnAdvancePeriod
        }
        if let returnForAdvancePeriod {
            return returnForAdvancePeriod
        } else {
            throw MockChartPeriodServiceError.didNotSetReturn
        }
    }
    
    public func returnPeriodMidDate(for: Period) throws -> Date {
        returnPeriodMidDateCalled = true
        if let shouldThrowOnReturnPeriodMidDate {
            throw shouldThrowOnReturnPeriodMidDate
        }
        if let returnForReturnPeriodMidDate {
            return returnForReturnPeriodMidDate
        } else {
            throw MockChartPeriodServiceError.didNotSetReturn
        }
    }
}

public enum MockChartPeriodServiceError: Error {
    case didNotSetReturn
}

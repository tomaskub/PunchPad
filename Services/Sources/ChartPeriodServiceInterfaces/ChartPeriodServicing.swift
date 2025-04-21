import DomainModels
import Foundation

public protocol ChartPeriodServicing: AnyObject {
    func generatePeriod(for: Date, in: ChartTimeRange) throws -> Period
    func generatePeriod(from: Entry, to: Entry) throws -> Period
    func retardPeriod(by: ChartTimeRange, from: Period) throws -> Period
    func advancePeriod(by: ChartTimeRange, from: Period) throws -> Period
    func returnPeriodMidDate(for: Period) throws -> Date
}


//
//  PreviewDataManager.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 05/05/2024.
//
import DomainModels
import Foundation
import FoundationExtensions
import Combine
import OSLog

public final class PreviewDataManager: NSObject, DataManaging {
    public var dataDidChange = PassthroughSubject<Void, Never>()
    private var data = [Entry]()
    private let logger = Logger.dataManager
    
    public init(with initialData: [Entry]? = nil) {
        super.init()
        logger.debug("Initializing sata manager")
        if let initialData {
            data = initialData
        } else {
            data = buildDataForPreviewForYear()
        }
        dataDidChange.send()
    }
    
    public func updateAndSave(entry: Entry) {
        logger.debug("updateAndSave called")
        data.append(entry)
        dataDidChange.send()
    }
    
    public func delete(entry: Entry) {
        logger.debug("delete called")
        data.removeAll { $0.id == entry.id }
        dataDidChange.send()
    }
    
    public func deleteAll() {
        logger.debug("deleteAll called")
        data = .init()
        dataDidChange.send()
    }
    
    public func fetch(forDate date: Date) -> Entry? {
        logger.debug("fetchForDate called")
        return data.first { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
    }
    
    public func fetch(for period: Period) -> [Entry]? {
        logger.debug("fetchForPeriod called")
        return fetch(from: period.0, to: period.1)
    }
    
    public func fetch(from startDate: Date?,
               to finishDate: Date?,
               ascendingOrder: Bool = false,
               fetchLimit: Int? = nil) -> [Entry]? {
        logger.debug("fetch called")
        var result = data.filter { data in
            if let startDate, let finishDate {
                return data.finishDate > startDate && data.finishDate < finishDate
            } else if let startDate {
                return data.finishDate > startDate
            } else if let finishDate {
                return data.finishDate < finishDate
            }
            return true
        }
        
        if ascendingOrder {
            result.sort(by: { $0.finishDate < $1.finishDate })
        } else {
            result.sort(by: { $0.finishDate > $1.finishDate})
        }
        
        if let fetchLimit, result.count > fetchLimit {
            return result.dropLast(result.count - fetchLimit)
        }
        
        return result
    }
    
    public func fetchOldestExisting() -> Entry? {
        logger.debug("fetchOldest called")
        return data.min { $0.startDate < $1.startDate }
    }
    
    public func fetchNewestExisting() -> Entry? {
        logger.debug("fetchNewest called")
        return data.max { $0.startDate > $1.startDate }
    }
    
    private  func buildDataForPreviewForYear(containing date: Date = Date(),
                                             using calendar: Calendar = .current) -> [Entry] {
        var result = [Entry]()
        let year = calendar.dateComponents([.year], from: date).year!
        for month in 1...12 {
            guard let dateInMonth = calendar.date(from: DateComponents(year: year, month: month)) else { continue }
            let dataForMonth = buildDataForPreviewForMonth(containing: dateInMonth, using: calendar)
            result.append(contentsOf: dataForMonth)
        }
        return result
    }
    
    private func buildDataForPreviewForMonth(containing date: Date = Date(),
                                            using calendar: Calendar = Calendar.current) -> [Entry] {
        let currentDate = calendar.startOfDay(for: date)
        guard let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: currentDate) else { return [] }
        let dateComponents = calendar.dateComponents([.year, .month], from: currentDate)
        var result = [Entry]()
        for day in numberOfDaysInMonth {
            var localDateComponents = dateComponents
            localDateComponents.day = day
            guard let workingDate = calendar.date(from: localDateComponents),
                  !calendar.isDateInWeekend(workingDate),
                  let entry = buildDataForDay(for: workingDate, using: calendar) else { continue }
            result.append(entry)
        }
        return result
    }
    
    private func buildDataForDay(for dayDate: Date = Date(),
                                        using calendar: Calendar = .current,
                                        startDateVariation: ClosedRange<Int> = 0...4,
                                        timeLengthVariation: ClosedRange<Int> = -4...4) -> Entry? {
        let randomStartComponent = Int.random(in: startDateVariation)
        let randomLengthComponent = Int.random(in: timeLengthVariation)
        let workTime = randomLengthComponent < 0 ? (8 + randomLengthComponent) * 3600 : 8 * 3600
        let overtime = randomLengthComponent <= 0 ? 0 : randomLengthComponent * 3600
        guard let startDate = calendar.date(byAdding: .hour, value: 6 + randomStartComponent, to: dayDate),
              let finishDate = calendar.date(byAdding: .hour, value: 8 + randomLengthComponent, to: startDate) else {
            return nil
        }
        return Entry(
            startDate: startDate,
            finishDate: finishDate,
            workTimeInSec: workTime,
            overTimeInSec: overtime,
            maximumOvertimeAllowedInSeconds: 5*3600,
            standardWorktimeInSeconds: 8*3600,
            grossPayPerMonth: 10000,
            calculatedNetPay: nil
        )
    }
}

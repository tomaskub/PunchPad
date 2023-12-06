//
//  PreviewDataFactory.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 04/12/2023.
//

import Foundation

struct PreviewDataFactory {
    static func buildDataForPreviewForYear(containing date: Date = Date(), using calendar: Calendar = .current) -> [Entry] {
        var result = [Entry]()
        let year = calendar.dateComponents([.year], from: date).year!
        for i in 1...12 {
            guard let dateInMonth = calendar.date(from: DateComponents(year: year, month: i)) else { print("Failed to get date in month where i = \(i)")
            break }
            let dataForMonth = buildDataForPreviewForMonth(containing: dateInMonth, using: calendar)
            result.append(contentsOf: dataForMonth)
        }
        return result
    }
    
    static func buildDataForPreviewForMonth(containing date: Date = Date(), using calendar: Calendar = Calendar.current) -> [Entry] {
        let currentDate = calendar.startOfDay(for: date)
        guard let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: currentDate) else { return [] }
        let dateComponents = calendar.dateComponents([.year,.month], from: currentDate)
        var result = [Entry]()
        for i in numberOfDaysInMonth {
            var localDateComponents = dateComponents
            localDateComponents.day = i
            guard let workingDate = calendar.date(from: localDateComponents),
                  !calendar.isDateInWeekend(workingDate),
                  let entry = buildDataForDay(for: workingDate, using: calendar) else { break }
            result.append(entry)
        }
        return result
    }
    
    static private func buildDataForDay(for dayDate: Date = Date(), 
                                        using calendar: Calendar = .current,
                                        startDateVariation: ClosedRange<Int> = 0...4,
                                        timeLengthVariation: ClosedRange<Int> = -4...4) -> Entry? {
        let randomStartComponent = Int.random(in: startDateVariation)
        let randomLengthComponent = Int.random(in: timeLengthVariation)
        let workTime = randomLengthComponent < 0 ? (8 + randomLengthComponent) * 3600 : 8 * 3600
        let overtime = randomLengthComponent <= 0 ? 0 : randomLengthComponent * 3600
        guard let startDate = calendar.date(byAdding: .hour, value: 6 + randomStartComponent, to: dayDate),
              let finishDate = calendar.date(byAdding: .hour, value: 8 + randomLengthComponent, to: startDate) else { return nil }
        return Entry(
            startDate: startDate,
            finishDate: finishDate,
            workTimeInSec: workTime,
            overTimeInSec: overtime
        )
    }
}

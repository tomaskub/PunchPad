//
//  PreviewDataFactory.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 04/12/2023.
//

import Foundation

struct PreviewDataFactory {
    
    static func buildDataForPreviewForMonth(containing date: Date = Date(), using calendar: Calendar = Calendar.current) -> [Entry] {
        let currentDate = calendar.startOfDay(for: date)
        guard let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: currentDate) else { return [] }
        let dateComponents = calendar.dateComponents([.year,.month], from: currentDate)
        var result = [Entry]()
        for i in numberOfDaysInMonth {
            var localDateComponents = dateComponents
            localDateComponents.day = i
            let workingDate = calendar.date(from: localDateComponents)!
            let randomStartComponent = Int.random(in: 0...4)
            let randomLengthComponent = Int.random(in: -4...4)
            let workTime = randomLengthComponent < 0 ? (8 + randomLengthComponent) * 3600 : 8 * 3600
            let overtime = randomLengthComponent <= 0 ? 0 : randomLengthComponent * 3600
                
            guard let startDate = calendar.date(byAdding: .hour, value: 6 + randomStartComponent, to: workingDate),
                  let finishDate = calendar.date(byAdding: .hour, value: 8 + randomLengthComponent, to: startDate) else { return [] }
            let entryToSave = Entry(
                startDate: startDate,
                finishDate: finishDate,
                workTimeInSec: workTime,
                overTimeInSec: overtime
            )
            result.append(entryToSave)
        }
        return result
    }
}

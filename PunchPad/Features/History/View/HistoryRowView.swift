//
//  HistoryRow.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/31/23.
//

import SwiftUI
import ThemeKit

struct HistoryRowView: View {
    private let timeIntervalFormatter = FormatterFactory.makeHourAndMinuteDateComponentFormatter()
    private let timeFormatter: DateFormatter = FormatterFactory.makeTimeFormatter()
    private let dateFormatter: DateFormatter = FormatterFactory.makeDateFormatter()
    private let startDate: Date
    private let finishDate: Date
    private let workTimeInSeconds: Int
    private let overTimeInSeconds: Int
    private let maximumOvertimeAllowedInSeconds: Int
    private let standardWorktimeInSeconds: Int
    
    init(startDate: Date,
         finishDate: Date,
         workTimeInSeconds: Int,
         overTimeInSeconds: Int,
         maximumOvertimeAllowedInSeconds: Int,
         standardWorktimeInSecons: Int) {
        self.startDate = startDate
        self.finishDate = finishDate
        self.workTimeInSeconds = workTimeInSeconds
        self.overTimeInSeconds = overTimeInSeconds
        self.maximumOvertimeAllowedInSeconds = maximumOvertimeAllowedInSeconds
        self.standardWorktimeInSeconds = standardWorktimeInSecons
    }
    
    init(withEntry entry: Entry) {
        self.startDate = entry.startDate
        self.finishDate = entry.finishDate
        self.workTimeInSeconds = entry.workTimeInSeconds
        self.overTimeInSeconds = entry.overTimeInSeconds
        self.maximumOvertimeAllowedInSeconds = entry.maximumOvertimeAllowedInSeconds
        self.standardWorktimeInSeconds = entry.standardWorktimeInSeconds
    }
    
    private var timeInterval: TimeInterval {
        TimeInterval(workTimeInSeconds + overTimeInSeconds)
    }
    private var maximumTime: Int {
        maximumOvertimeAllowedInSeconds + standardWorktimeInSeconds
    }
    
    var body: some View {
        Grid(alignment: .leading) {
            GridRow {
                dateLabel
                timeIntervalLabel
                    .gridColumnAlignment(.trailing)
            }
            GridRow {
                timeLabel
                indicator()
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            Color.theme.white
                .cornerRadius(10)
        )
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func indicator() -> some View {
        ZStack(alignment: .leading) {
            GeometryReader { proxy in
                Rectangle()
                    .foregroundColor(.theme.ringWhite)
                Rectangle()
                    .foregroundColor(.theme.primary)
                    .frame(width: getWorkTimeIndicatorWidth(in: proxy.size.width))
                Rectangle()
                    .foregroundColor(.theme.redChart)
                    .frame(width: getOvertimeIndicatorWidth(in: proxy.size.width))
                    .offset(x: getWorkTimeIndicatorWidth(in: proxy.size.width))
            }
        }
        .frame(height: 6)
        .frame(maxWidth: .infinity)
    }
    
    private var timeLabel: some View {
        Text(makeTimeLabel(from: startDate, to: finishDate))
            .font(.system(size: 16))
            .foregroundColor(.theme.blackLabel)
    }
    
    private var dateLabel: some View {
        Text(dateFormatter.string(from: startDate).uppercased())
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(.theme.primary)
    }
    
    private var timeIntervalLabel: some View {
        Text(makeTimeIntervalLabel(for: timeInterval))
            .font(.system(size: 16))
            .foregroundColor(.theme.secondaryLabel)
    }
    
    func getWorkTimeIndicatorWidth(in width: CGFloat) -> CGFloat {
        let fraction: Double = Double(workTimeInSeconds) / Double(maximumTime)
        let result = width * CGFloat(fraction)
        return result.isNaN ? 0 : result
    }
    
    func getOvertimeIndicatorWidth(in width: CGFloat) -> CGFloat {
        let fraction: Double = Double(overTimeInSeconds) / Double(maximumTime)
        let result = width * CGFloat(fraction)
        return result.isNaN ? 0 : result
    }
    
    private func makeTimeIntervalLabel(for timeInterval: TimeInterval) -> String {
        guard var result = timeIntervalFormatter.string(from: timeInterval) else { return String() }
        let startIndex = result.index(result.startIndex, offsetBy: 2)
        let endIndex = result.index(after: startIndex)
        result.removeSubrange(startIndex..<endIndex)
        result.insert(contentsOf: " \(Strings.hoursText) ", at: startIndex)
        result.append(" \(Strings.minutesText)")
        return result
    }
    
    private func makeTimeLabel(from start: Date, to end: Date) -> String {
        "\(timeFormatter.string(from: start)) - \(timeFormatter.string(from: end))"
    }
}

// MARK: - Localization
extension HistoryRowView: Localized {
    struct Strings {
        static let hoursText = Localization.Common.hours
        static let minutesText = Localization.Common.minutesShort
    }
}
#Preview {
    struct Preview: View {
        
        var body: some View {
            ZStack {
                BackgroundFactory.buildSolidColor()
                
                List {
                    HistoryRowView(
                        startDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
                        finishDate: Calendar.current.date(byAdding: .hour, value: 6, to: Date())!,
                        workTimeInSeconds: 8 * 3600,
                        overTimeInSeconds: 0,
                        maximumOvertimeAllowedInSeconds: 5 * 3600,
                        standardWorktimeInSecons: 8 * 3600
                    )
                    HistoryRowView(
                        startDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
                        finishDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())!,
                        workTimeInSeconds: 8 * 3600,
                        overTimeInSeconds: 2 * 3600,
                        maximumOvertimeAllowedInSeconds: 5 * 3600,
                        standardWorktimeInSecons: 8 * 3600
                    )
                    HistoryRowView(
                        startDate: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
                        finishDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())!,
                        workTimeInSeconds: 8 * 3600,
                        overTimeInSeconds: 5 * 3600,
                        maximumOvertimeAllowedInSeconds: 5 * 3600,
                        standardWorktimeInSecons: 8 * 3600
                    )
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
        }
    }
    return Preview()
}

//
//  StatisticsView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import Charts
import DomainModels
import FoundationExtensions
import SwiftUI
import ThemeKit
import UIComponents

struct StatisticsView: View {
    private typealias Identifier = ScreenIdentifier.StatisticsView
    private let currencyFormatter = FormatterFactory.makeCurrencyFormatter(Locale.current)
    private let dateFormatter = FormatterFactory.makeDateFormatter()
    @ObservedObject private var viewModel: StatisticsViewModel
    
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Body
extension StatisticsView {
    var body: some View {
        ZStack {
            background
            
            List {
                ChartTimeRangePicker(pickerSelection: $viewModel.chartTimeRange)
                    .padding(.horizontal, -20)
                    .listRowBackground(Color.clear)
                
                Section {
                    VStack(alignment: .leading) {
                        hoursCount
                        displayedChartRange
                    }
                    chart
                        .frame(height: 260)
                        .gesture(DragGesture()
                            .onEnded { value in
                                switch detectDirection(value: value) {
                                case .left:
                                    viewModel.loadPreviousPeriod()
                                case .right:
                                    viewModel.loadNextPeriod()
                                default:
                                    break
                                }
                            }
                        )
                }
                .listRowBackground(Color.theme.white)
                .listRowSeparator(.hidden)
                
                Section {
                    newGrossData
                } header: {
                    TextFactory.buildSectionHeader(Strings.salaryCalculationHeaderText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.salaryCalculation.rawValue)
                }
                .listRowBackground(Color.theme.white)
                
                Color.clear.frame(height: 80)
                    .listRowBackground(Color.clear)
            }
            .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
            .scrollContentBackground(.hidden)
        }
    }
}

// MARK: - Swipe Gestures
private extension StatisticsView {
    enum SwipeDirection: String {
        case left, right, up, down, none
    }
    
    func detectDirection(value: DragGesture.Value, _ tolerance: Double = 24) -> SwipeDirection {
        if value.startLocation.x < value.location.x - tolerance {
            return .left
        }
        if value.startLocation.x > value.location.x + tolerance {
            return .right
        }
        if value.startLocation.y < value.location.y - tolerance {
            return .down
        }
        if value.startLocation.y > value.location.y + tolerance {
            return .up
        }
        return .none
    }
}

// MARK: - Auxiliary View Components
private extension StatisticsView {
    var background: some View {
        BackgroundFactory.buildSolidColor()
    }
}

// MARK: - Chart Views
private extension StatisticsView {
    struct ChartTimeRangePicker: View {
        @Binding var pickerSelection: ChartTimeRange
        
        init(pickerSelection: Binding<ChartTimeRange>) {
            self._pickerSelection = pickerSelection
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.theme.white)
            
            UISegmentedControl.appearance().setTitleTextAttributes(
                [.foregroundColor: UIColor(Color.theme.primary)],
                for: .selected
            )
            
            UISegmentedControl.appearance().setTitleTextAttributes(
                [.foregroundColor: UIColor(Color.theme.white)],
                for: .normal
            )
        }
        
        var body: some View {
            Picker(String(), selection: $pickerSelection) {
                ForEach(ChartTimeRange.allCases) { range in
                    Text(range.rawValue.capitalized)
                        .accessibilityIdentifier(range.mapToIdentifier())
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    @ViewBuilder
    var chart: some View {
        // TODO: ask about the issue:
        // Referencing subscript 'subscript(dynamicMember:)' requires
        // wrapper 'ObservedObject<StatisticsViewModel>.Wrapper'
        switch viewModel.chartTimeRange {
        case .week, .month:
            ChartFactory.buildBarChartForDays(data: viewModel.entryInPeriod)
        case .year:
            ChartFactory.buildBarChartForMonths(data: viewModel.entrySummaryByMonthYear)
        case .all:
            if let groupedByWeek = viewModel.entrySummaryByWeekYear {
                ChartFactory.buildBarChartForWeeks(data: groupedByWeek)
            } else {
                ChartFactory.buildBarChartForMonths(data: viewModel.entrySummaryByMonthYear)
            }
        }
    }
    
    func makePeriodRangeString(for period: Period, selectedRange: ChartTimeRange) -> String {
        switch selectedRange {
        case .week:
            return makePeriodRangeForWeek(for: period)
        case .month:
            return FormatterFactory.makeFullMonthYearDateFormatter().string(from: period.0)
        case .year:
            return FormatterFactory.makeYearDateFormatter().string(from: period.0)
        case .all:
            return makePeriodRangeFullDatesString(for: period)
        }
    }
    
    func makePeriodRangeForWeek(for period: Period) -> String {
        let endDateFormatter = FormatterFactory.makeDateFormatter()
        let endString = endDateFormatter.string(from: period.1)
        let startFormatter: DateFormatter? = {
            let periodEndMonth = Calendar.current.dateComponents([.month], from: period.1)
            let periodEndYear = Calendar.current.dateComponents([.year], from: period.1)
            if Calendar.current.date(period.0, matchesComponents: periodEndMonth) {
                return  FormatterFactory.makeDayDateFormatter()
            } else if Calendar.current.date(period.0, matchesComponents: periodEndYear) {
                return FormatterFactory.makeDayAndMonthDateFormatter()
            }
            return nil
        }()
        guard let startFormatter else {
            return makePeriodRangeFullDatesString(for: period)
        }
        let startString = startFormatter.string(from: period.0)
        return startString + " - " + endString
    }
    
    func makePeriodRangeFullDatesString(for period: Period) -> String {
        let formatter = FormatterFactory.makeDateFormatter()
        let startString = formatter.string(from: period.0)
        let finishString = formatter.string(from: period.1)
        return startString + " - " + finishString
    }
    
    var displayedChartRange: some View {
        Text(makePeriodRangeString(for: viewModel.periodDisplayed,
                                   selectedRange: viewModel.chartTimeRange)
        )
        .foregroundStyle(Color.theme.buttonLabelGray)
        .font(.caption)
    }
    
    var hoursCount: some View {
        HStack {
                HStack(spacing: 8) {
                    Text(String(viewModel.workedHoursInPeriod))
                        .font(.title)
                    Text("hours worked")
                        .font(.caption)
                }
            Spacer()
            HStack(spacing: 8) {
                Text(String(viewModel.overtimeHoursInPeriod))
                    .font(.title)
                Text("hours overtime")
                    .font(.caption)
            }
            Spacer()
            Image(systemName: "calendar")
                .opacity(0)
                .foregroundColor(.theme.primary)
                .font(.title)
        }
        .foregroundColor(.theme.black)
    }
}

// MARK: - Salary Views
private extension StatisticsView {
    var newGrossData: some View {
        Group {
            SalaryListRowView(propertyName: Strings.periodListRowTitle,
                              propertyValue: makePeriodRangeString(
                                for: viewModel.grossSalaryData.period,
                                selectedRange: viewModel.chartTimeRange
                              )
            )
            .accessibilityIdentifier(Identifier.SalaryCalculationLabel.period)
            SalaryListRowView(propertyName: Strings.grossPayPerHourListRowTitle,
                              propertyValue: currencyFormatter.string(
                                from: viewModel.grossSalaryData.payPerHour as NSNumber
                              ) ?? String()
            )
            .accessibilityIdentifier(Identifier.SalaryCalculationLabel.grossPayPerHour)
            
            SalaryListRowView(propertyName: Strings.grossPayListRowTitle,
                              propertyValue: currencyFormatter.string(
                                from: viewModel.grossSalaryData.payUpToDate as NSNumber
                              ) ?? String()
            )
            .accessibilityIdentifier(Identifier.SalaryCalculationLabel.grossPay)
            
            if let payPredicted = viewModel.grossSalaryData.payPredicted {
                SalaryListRowView(propertyName: Strings.grossPayPredictedListRowTitle,
                                  propertyValue: currencyFormatter.string(from: payPredicted as NSNumber) ?? String()
                )
                .accessibilityIdentifier(Identifier.SalaryCalculationLabel.grossPayPredicted)
            }
            SalaryListRowView(propertyName: Strings.numberOfWorkingDaysListRowTitle,
                              propertyValue: String(viewModel.grossSalaryData.numberOfWorkingDays)
                                
            )
            .accessibilityIdentifier(Identifier.SalaryCalculationLabel.workingDaysNumber)
        }
    }
    struct SalaryListRowView: View {
        let propertyName: String
        let propertyValue: String
        
        var body: some View {
            HStack {
                Text(propertyName)
                    .foregroundColor(.theme.blackLabel)
                    .font(.system(size: 16))
                Spacer()
                Text(propertyValue)
                    .foregroundColor(.theme.primary)
                    .font(.system(size: 20))
            }
        }
    }
}

extension StatisticsView: Localized {
    struct Strings {
        static let salaryCalculationHeaderText = Localization.StatisticsScreen.salaryCalculation
        static let chartTitleText = Localization.StatisticsScreen.timeWorked
        static let periodListRowTitle = Localization.StatisticsScreen.period
        static let grossPayPerHourListRowTitle = Localization.StatisticsScreen.grossPayPerHour
        static let grossPayListRowTitle = Localization.StatisticsScreen.grossPay
        static let grossPayPredictedListRowTitle = Localization.StatisticsScreen.grossPayPredicted
        static let numberOfWorkingDaysListRowTitle = Localization.StatisticsScreen.numberOfWorkingDays
    }
}
#Preview {
    struct Preview: View {
        private let container = PreviewContainer()
        var body: some View {
            StatisticsView(viewModel:
                            StatisticsViewModel(
                                dataManager: container.dataManager,
                                payManager: container.payManager,
                                settingsStore: container.settingsStore,
                                calendar: .current
                            )
            )
        }
    }
    return Preview()
}

private extension ChartTimeRange {
    func mapToIdentifier() -> ScreenIdentifier.StatisticsView.SegmentedControl {
        return switch self {
        case .all:
                .allRange
        case .year:
                .yearRange
        case .month:
                .monthRange
        case .week:
                .weekRange
        }
    }
}

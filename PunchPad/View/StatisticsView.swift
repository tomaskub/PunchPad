//
//  StatisticsView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import SwiftUI
import Charts
import ThemeKit

struct StatisticsView: View {
    private typealias Identifier = ScreenIdentifier.StatisticsView
    //MARK: PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var container: Container
    @ObservedObject var viewModel: StatisticsViewModel
    let currencyFormatter = FormatterFactory.makeCurrencyFormatter(Locale.current)
    let dateFormatter = FormatterFactory.makeDateFormatter()
    let salaryCalculationHeaderText: String = "Salary calculation"
    let chartTitleText: String = "time worked"
    
    //MARK: VIEW BODY
    var body: some View {
        ZStack {
            background
            // CONTENT LAYER
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
                }//END OF SECTION
                .listRowBackground(Color.theme.white)
                .listRowSeparator(.hidden)
                
                Section {
                    newGrossData
                } header: {
                    TextFactory.buildSectionHeader(salaryCalculationHeaderText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.salaryCalculation.rawValue)
                }// END OF SECTION
                .listRowBackground(Color.theme.white)
                Color.clear.frame(height: 80)
                    .listRowBackground(Color.clear)
            } //END OF LIST
            .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
            .scrollContentBackground(.hidden)
        } // END OF ZSTACK
    } //END OF VIEW
}

//MARK: SWIPE GESTURES
extension StatisticsView {
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

//MARK: AUX. UI ELEMENTS
extension StatisticsView {
    var background: some View {
        BackgroundFactory.buildSolidColor()
    }
}

//MARK: CHART VIEW BUILDERS & VARIABLES
extension StatisticsView {
    private struct ChartTimeRangePicker: View {
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
                    Text(range.rawValue.capitalized)}
            }
            .pickerStyle(.segmented)
        }
    }
    
    @ViewBuilder
    var chart: some View {
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
    } // END OF VAR
    
    private func makePeriodRangeString(for period: Period, selectedRange: ChartTimeRange) -> String {
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
    
    private func makePeriodRangeForWeek(for period: Period) -> String {
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
    
    private func makePeriodRangeFullDatesString(for period: Period) -> String {
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

//MARK: DATA VIEW BUILDERS
extension StatisticsView {
    var newGrossData: some View {
        Group {
            SalaryListRowView(propertyName: "Period",
                              propertyValue: makePeriodRangeString(
                                for: viewModel.grossSalaryData.period,
                                selectedRange: viewModel.chartTimeRange
                              )
            )
            SalaryListRowView(propertyName: "Gross pay per hour",
                              propertyValue: currencyFormatter.string(from: viewModel.grossSalaryData.payPerHour as NSNumber) ?? String()
            )
            SalaryListRowView(propertyName: "Gross pay",
                              propertyValue: currencyFormatter.string(from: viewModel.grossSalaryData.payUpToDate as NSNumber) ?? String()
            )
            if let payPredicted = viewModel.grossSalaryData.payPredicted {
                SalaryListRowView(propertyName: "Gross pay predicted",
                                  propertyValue: currencyFormatter.string(from: payPredicted as NSNumber) ?? String()
                )
            }
            SalaryListRowView(propertyName: "Number of working days",
                              propertyValue: String(viewModel.grossSalaryData.numberOfWorkingDays)
                                
            )
        }
    }
    private struct SalaryListRowView: View {
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

#Preview {
    struct Preview: View {
        @State private var container = Container()
        var body: some View {
            StatisticsView(viewModel:
                            StatisticsViewModel(
                                dataManager: container.dataManager,
                                payManager: container.payManager,
                                settingsStore: container.settingsStore,
                                calendar: .current
                            )
            )
            .environmentObject(container)
        }
    }
    return Preview()
}

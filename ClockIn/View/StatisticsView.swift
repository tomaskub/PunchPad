//
//  StatisticsView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    private typealias Identifier = ScreenIdentifier.StatisticsView
    //MARK: PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var container: Container
    @ObservedObject var viewModel: StatisticsViewModel
    
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
                .listRowSeparator(.hidden)
                
                Section {
                    if viewModel.netPayAvaliable {
                        netSalaryData
                    } // END OF IF
                     grossSalaryData
                } header: {
                    TextFactory.buildSectionHeader(salaryCalculationHeaderText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.salaryCalculation.rawValue)
                }// END OF SECTION
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
            ChartFactory.buildBarChart(entries: viewModel.entriesForChart,
                                       firstColor: .theme.primary,
                                       secondColor: .theme.redChart
            )
        case .year, .all:
            ChartFactory.buildBarChartForYear(
                data: viewModel.createMonthlySummary(entries: viewModel.entriesForChart),
                firstColor: .theme.primary,
                secondColor: .theme.redChart
            )
        }
    } // END OF VAR
    
    func makeChartRangeString(for period: Period) -> String {
        let periodEndMonth = Calendar.current.dateComponents([.month], from: period.1)
        let periodEndYear = Calendar.current.dateComponents([.year], from: period.1)
        let isSameMonth = Calendar.current.date(period.0, matchesComponents: periodEndMonth)
        if isSameMonth {
            let startDay = Calendar.current.dateComponents([.day], from: period.0)
            return "\(startDay.day ?? 0) - \(period.1.formatted(date: .abbreviated, time: .omitted))"
        }
        let isSameYear = Calendar.current.date(period.0, matchesComponents: periodEndYear)
        if isSameYear {
            let startString = String(period.0.formatted(date: .abbreviated, time: .omitted).dropLast(5))
            return startString + " - " + period.1.formatted(date: .abbreviated, time: .omitted)
        }
        return period.0.formatted(date: .abbreviated, time: .omitted) + " - " + period.1.formatted(date: .abbreviated, time: .omitted)
    }
    
    var displayedChartRange: some View {
        Text(makeChartRangeString(for: viewModel.periodDisplayed))
            .foregroundStyle(.secondary)
            .font(.caption)
    }
    
    var hoursCount: some View {
        HStack {
                HStack(spacing: 8) {
                    Text(String(viewModel.workedHoursInPeriod))
                        .font(.title)
                    Text("hours worked")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            Spacer()
            HStack(spacing: 8) {
                Text(String(viewModel.overtimeHoursInPeriod))
                    .font(.title)
                Text("hours overtime")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            Spacer()
            Image(systemName: "calendar")
                .opacity(0)
                .foregroundColor(.theme.primary)
                .font(.title)
        }
    }
}

//MARK: DATA VIEW BUILDERS
extension StatisticsView {
    var netSalaryData: some View {
        ForEach(viewModel.salaryListDataNetPay, id: \.0) { data in
            SalaryListRowView(propertyName: data.0,
                              propertyValue: data.1)
        } // END OF FOR EACH
    }
    var grossSalaryData: some View {
        ForEach(viewModel.salaryListDataGrossPay, id: \.0) { data in
            SalaryListRowView(propertyName: data.0,
                              propertyValue: data.1)
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
                                settingsStore: container.settingsStore)
            )
            .environmentObject(container)
        }
    }
    return Preview()
}

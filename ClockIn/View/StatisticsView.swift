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
    @StateObject private var viewModel: StatisticsViewModel
    @State var chartType: ChartType = .time
    
    let navTitleText: String = "Statistics"
    let salaryCalculationHeaderText: String = "Salary calculation"
    var chartTitle: String {
        switch chartType {
        case .finishTime:
            return "Time finished"
        case .startTime:
            return "Time started"
        case .time:
            return "Time worked"
        }
    }
    
    init(viewModel: StatisticsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: VIEW BODY
    var body: some View {
        ZStack {
            background
            // CONTENT LAYER
            List {
                Section {
                    chart
                        .padding(.top, 16)
                    chartTypePicker
                } header: {
                    sectionHeader(chartTitle)
                        .accessibilityIdentifier(Identifier.SectionHeaders.chart.rawValue)
                }//END OF SECTION
                
                Section {
                    if viewModel.netPayAvaliable {
                        ForEach(viewModel.salaryListDataNetPay, id: \.0) { data in
                            HStack{
                                Text(data.0)
                                Spacer()
                                Text(data.1)
                            } // END OF HSTACK
                        } // END OF FOR EACH
                    } // END OF IF
                    ForEach(viewModel.salaryListDataGrossPay, id: \.0) { data in
                        HStack{
                            Text(data.0)
                            Spacer()
                            Text(data.1)
                        } // END OF HSTACK
                    } // END OF FOR EACH
                } header: {
                    sectionHeader(salaryCalculationHeaderText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.salaryCalculation.rawValue)
                }// END OF SECTION
            } //END OF LIST
            .scrollContentBackground(.hidden)
            .toolbar { toolbar }
            .navigationTitle(navTitleText)
        } // END OF ZSTACK
    } //END OF VIEW
}

//MARK: AUX. UI ELEMENTS
extension StatisticsView {
    var chartTypePicker: some View {
        Picker("Chart type", selection: $chartType) {
            Text("Time")
                .tag(ChartType.time)
                .accessibilityIdentifier(Identifier.ChartTypeButton.workTime.rawValue)
            Text("Start time")
                .tag(ChartType.startTime)
                .accessibilityIdentifier(Identifier.ChartTypeButton.startTime.rawValue)
            Text("Finish time")
                .tag(ChartType.finishTime)
                .accessibilityIdentifier(Identifier.ChartTypeButton.finishTime.rawValue)
        }
        .accessibilityIdentifier(Identifier.SegmentedControl.chartType.rawValue)
        .pickerStyle(.segmented)
    } // END OF VAR
    var background: some View {
        BackgroundFactory.buildSolidColor()
    }
    
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            //TODO: REPLACE WITH SETTINGS LINK - settings link does not work for some reason?
            NavigationLink {
                HistoryView(viewModel:
                                HistoryViewModel(
                                    dataManager: container.dataManager,
                                    settingsStore: container.settingsStore)
                )
            } label: {
                Label("Settings", systemImage: "gearshape.fill")
            } // END OF NAV LINK
            .tint(.primary)
            .accessibilityIdentifier(Identifier.NavigationBarButtons.detailedHistory.rawValue)
        } // END OF TOOLBAR ITEM
    }
    
    @ViewBuilder
    func sectionHeader(_ text: String) -> some View {
        Text(text)
            .bold()
            .foregroundColor(.primary)
    }
}

extension StatisticsView {
    @ViewBuilder
    var chart: some View {
        switch chartType {
        case .time:
            chartWorkTime
            chartWorkTimeLegend
        case .startTime:
            chartStartTime
            chartStartTimeLegend
        case .finishTime:
            chartFinishTime
            chartFinishTimeLegend
        } // END OF SWITCH
    } // END OF VAR
    
    var chartWorkTime: some View {
        Chart(viewModel.entriesForChart) {
            RuleMark(y: .value("WorkGoal", 8))
                .lineStyle(.init(dash: [10]))
                .foregroundStyle(.red)
            
            BarMark(
                x: .value("Date", $0.startDate, unit: .day),
                y: .value("Hours worked", $0.workTimeInSeconds / 3600))
            .foregroundStyle(.blue)
            .cornerRadius(10)
            BarMark(x: .value("Date", $0.startDate,unit: .day),
                    y: .value("Hours worked", $0.overTimeInSeconds / 3600))
            .foregroundStyle(.green)
            .cornerRadius(10)
        }
        .accessibilityIdentifier(Identifier.Chart.workTimeChart.rawValue)
        //Additional chart properties x-axis and y-scale
        .chartYScale(domain: 0...15)
        
    } // END OF VAR
    
    var chartStartTime: some View {
        Chart(viewModel.entriesForChart) {
            PointMark(
                x: .value("Date", $0.startDate),
                y: .value("Date", Calendar.current.dateComponents([.hour, .minute], from:  $0.startDate).hour!)
            )
            .foregroundStyle($0.workTimeInSeconds == 0 ? .clear : .blue)
        }
        .accessibilityIdentifier(Identifier.Chart.startTimeChart.rawValue)
        .chartYScale(domain: 0...24)
    } // END OF VAR
    var chartFinishTime: some View {
        Chart(viewModel.entriesForChart) {
            PointMark(
                x: .value("Date", $0.startDate),
                y: .value("Date", Calendar.current.dateComponents([.hour, .minute], from:  $0.finishDate).hour!)
            )
            .foregroundStyle($0.workTimeInSeconds == 0 ? .clear : .red)
        }
        .accessibilityIdentifier(Identifier.Chart.finishTimeChart.rawValue)
        .chartYScale(domain: 0...24)
    } // END OF VAR
}

extension StatisticsView {
    var chartStartTimeLegend: some View {
        HStack {
            Text("Legend:")
            Circle()
                .fill(.blue)
                .frame(width: 14, height: 14)
            Text("Clock in")
        }
        .accessibilityIdentifier(Identifier.ChartLegend.startTimeChartLegend.rawValue)
        .font(.caption)
    } // END OF VAR
    var chartWorkTimeLegend: some View {
        HStack {
            Text("Legend:")
            Rectangle()
                .fill(.blue)
                .frame(width: 14, height: 14)
            Text("Working time")
            Rectangle()
                .fill(.green)
                .frame(width: 14, height: 14)
            Text("Overtime")
        }
        .accessibilityIdentifier(Identifier.ChartLegend.workTimeChartLegend.rawValue)
        .font(.caption)
    } // END OF VAR
    var chartFinishTimeLegend: some View {
        HStack {
            Text("Legend:")
            Circle()
                .fill(.red)
                .frame(width: 14, height: 14)
            Text("Clock out")
        }
        .accessibilityIdentifier(Identifier.ChartLegend.finishTimeChartLegend.rawValue)
        .font(.caption)
    } // END OF VAR
}


//MARK: PREVIEW
struct StatisticsView_Previews: PreviewProvider {
    private struct ContainerView: View {
        @StateObject private var container = Container()
        var body: some View {
            NavigationView {
                StatisticsView(viewModel:
                                StatisticsViewModel(
                                    dataManager: container.dataManager,
                                    payManager: container.payManager,
                                    settingsStore: container.settingsStore)
                               )
            }
            .environmentObject(container)
        }
    }
    static var previews: some View {
        ContainerView()
    }
}

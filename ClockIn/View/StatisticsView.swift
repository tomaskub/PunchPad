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
    @StateObject var viewModel: StatisticsViewModel = StatisticsViewModel()
    
    //MARK: VIEW BODY
    var body: some View {
        ZStack {
            // BACKGROUND LAYER
            GradientFactory.build(colorScheme: colorScheme)
            // CONTENT LAYER
            List {
                Section {
                    chart
                        .padding(.top, 16)
                    chartTypePicker
                } header: {
                    Text(chartTitle)
                        .accessibilityIdentifier(Identifier.SectionHeaders.chart.rawValue)
                        .bold()
                        .foregroundColor(.primary)
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
                    Text("Salary calculation")
                        .accessibilityIdentifier(Identifier.SectionHeaders.salaryCalculation.rawValue)
                }// END OF SECTION
            } //END OF LIST
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Text("Detailed history")
                    } // END OF NAV LINK
                    .accessibilityIdentifier(Identifier.NavigationBarButtons.detailedHistory.rawValue)
                } // END OF TOOLBAR ITEM
            } // END OF TOOLBAR
            .navigationTitle("Statistics")
        } // END OF ZSTACK
    } //END OF VIEW
    
    //MARK: UI ELEMENTS
    var chartTitle: String {
        switch viewModel.chartType {
        case .finishTime:
            return "Time finished"
        case .startTime:
            return "Time started"
        case .time:
            return "Time worked"
        }
    } // END OF VAR
    
    @ViewBuilder
    var chart: some View {
        switch viewModel.chartType {
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
    
    var chartTypePicker: some View {
        Picker("Chart type", selection: $viewModel.chartType) {
            Text("Time")
                .tag(ChartType.time)
                .accessibilityIdentifier(Identifier.ChartTypePicker.workTime.rawValue)
            Text("Start time")
                .tag(ChartType.startTime)
                .accessibilityIdentifier(Identifier.ChartTypePicker.startTime.rawValue)
            Text("Finish time")
                .tag(ChartType.finishTime)
                .accessibilityIdentifier(Identifier.ChartTypePicker.finishTime.rawValue)
        }
        .accessibilityIdentifier(Identifier.Picker.chartType.rawValue)
        .pickerStyle(.segmented)
    } // END OF VAR
}

//MARK: PREVIEW
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
        StatisticsView(viewModel:
                        StatisticsViewModel(
                            dataManager: .preview,
                            payManager: PayManager(dataManager: .preview)
                        ))
        }
    }
}

//
//  StatisticsView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: StatisticsViewModel = StatisticsViewModel()
    
    
    var body: some View {
        
        ZStack {
            //Background layer
            LinearGradient(colors: [ colorScheme == .light ? .white : .black, .blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            //Content layer
            List {
                Section {
                HStack{
                    switch viewModel.chartType {
                    case .time:
                        Text("Time worked")
                            .font(.title2)
                    case .startTime:
                        Text("Time started")
                            .font(.title2)
                    case .finishTime:
                        Text("Time finished")
                            .font(.title2)
                    }
                                            
                    Spacer()
                    Picker("Time:", selection: .constant(1)) {
                        Text("This month")
                        Text("Last 30 days")
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
                    switch viewModel.chartType {
                    case .time:
                        chartWorkTime
                    case .startTime:
                        chartStartTime
                    case .finishTime:
                        chartFinishTime
                    }
                
                    
                    VStack(alignment: .leading) {
                        Text("Legend:")
                        HStack {
                            Rectangle()
                                .fill(.blue)
                                .frame(width: 20, height: 20)
                            Text("Working time")
                            Rectangle()
                                .fill(.green)
                                .frame(width: 20, height: 20)
                            Text("Overtime")
                                
                        }
                        .font(.caption)
                    }
                    chartTypePicker
                
                
                } //END OF SECTION
                
                Section("Salary calculation"){
                    
                    ForEach(viewModel.salaryListData, id: \.0) { data in
                        HStack{
                            Text(data.0)
                            Spacer()
                            Text(data.1)
                        }
                        
                    }
                } // END OF SECTION
            } //END OF LIST
            
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Text("Detailed history")
                    }

                }
            }
            .navigationTitle("Statistics")
        }
    } //END OF VIEW
    
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
        //Additional chart properties x-axis and y-scale
        /*
                    .chartXAxis(content: {
                        AxisMarks(values: viewModel.entriesForChart.map({ $0.startDate})) { date in
                            AxisValueLabel(format: .dateTime.day(.twoDigits))
                        }
                    })
        .chartYScale(domain: 0...15)
         */
    }
    
    var chartStartTime: some View {
        Chart(viewModel.entriesForChart) {

                PointMark(
                    x: .value("Date", $0.startDate),
                    y: .value("Date", Calendar.current.dateComponents([.hour, .minute], from:  $0.startDate).hour!)
                )
                .foregroundStyle($0.workTimeInSeconds == 0 ? .clear : .blue)

        }
        .chartYScale(domain: 0...24)
    }
    
    var chartFinishTime: some View {
        Chart(viewModel.entriesForChart) {

                PointMark(
                    x: .value("Date", $0.startDate),
                    y: .value("Date", Calendar.current.dateComponents([.hour, .minute], from:  $0.finishDate).hour!)
                )
                .foregroundStyle($0.workTimeInSeconds == 0 ? .clear : .red)

        }
        .chartYScale(domain: 0...24)
    }
    
    
    var chartTypePicker: some View {
        
        Picker("Chart type", selection: $viewModel.chartType) {
        
            Text("Time").tag(ChartDataType.time)
            Text("Start time").tag(ChartDataType.startTime)
            Text("Finish time").tag(ChartDataType.finishTime)
            
        }
        .pickerStyle(.segmented)
    }
    
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
//        NavigationView {
        StatisticsView(viewModel:
                        StatisticsViewModel(
                            dataManager: .preview,
                            payManager: PayManager(dataManager: .preview)
                        ))
//        }
    }
}

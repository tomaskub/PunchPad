//
//  StatisticsView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    
    //MARK: PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: StatisticsViewModel = StatisticsViewModel()
    
    //MARK: VIEW BODY
    var body: some View {
        
        ZStack {
            //Background layer
            LinearGradient(colors: [ colorScheme == .light ? .white : .black, .blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            //Content layer
            List {
                Section {
                    
                    switch viewModel.chartType {
                    case .time:
                        
                        Text("Time worked")
                            .font(.title2)
                        chartWorkTime
                        chartWorkTimeLegend
                        
                    case .startTime:
                        
                        Text("Time started")
                            .font(.title2)
                        chartStartTime
                        chartStartTimeLegend
                        
                    case .finishTime:
                        
                        Text("Time finished")
                            .font(.title2)
                        chartFinishTime
                        chartFinishTimeLegend
                        
                    }
                    
                    chartTypePicker
                
                
                }//END OF SECTION
                
                Section("Salary calculation"){
                    if viewModel.netPayAvaliable {
                        ForEach(viewModel.salaryListDataNetPay, id: \.0) { data in
                            HStack{
                                Text(data.0)
                                Spacer()
                                Text(data.1)
                            }
                        }
                    }
                    ForEach(viewModel.salaryListDataGrossPay, id: \.0) { data in
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
    
    //MARK: UI ELEMENTS
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
        .chartYScale(domain: 0...15)
         
    }
    
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
        .font(.caption)
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
    
    var chartStartTimeLegend: some View {
        HStack {
            Text("Legend:")
            Circle()
                .fill(.blue)
                .frame(width: 14, height: 14)
            Text("Clock in")
    }
        .font(.caption)
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
    
    var chartFinishTimeLegend: some View {
        HStack {
            Text("Legend:")
            Circle()
                .fill(.red)
                .frame(width: 14, height: 14)
            Text("Clock out")
    }
        .font(.caption)
    }
    
    var chartTypePicker: some View {
        
        Picker("Chart type", selection: $viewModel.chartType) {
        
            Text("Time").tag(ChartType.time)
            Text("Start time").tag(ChartType.startTime)
            Text("Finish time").tag(ChartType.finishTime)
            
        }
        .pickerStyle(.segmented)
    }
    
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

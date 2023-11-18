//
//  StatisticsView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/16/23.
//

import SwiftUI
import Charts
enum ChartTimeRange {
    case week
    case month
    case year
    case all
}
struct StatisticsView: View {
    private typealias Identifier = ScreenIdentifier.StatisticsView
    
    //MARK: PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var container: Container
    @StateObject private var viewModel: StatisticsViewModel
    
    let navTitleText: String = "Statistics"
    let salaryCalculationHeaderText: String = "Salary calculation"
    let chartTitleText: String = "time worked"
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
                    chartTimeRangePicker
                    VStack(alignment: .leading) {
                        HStack(alignment: .bottom, spacing: 16) {
                            VStack(alignment: .leading ) {
                                Text("worked".uppercased())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                HStack(alignment: .bottom, spacing: 0) {
                                    Text(String(generateTotalHoursWorked()))
                                        .font(.title)
                                    Text("hours")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                            VStack(alignment: .leading ) {
                                Text("overtime".uppercased())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                HStack(alignment: .bottom, spacing: 0) {
                                    Text(String(generateTotalHoursOvertime()))
                                        .font(.title)
                                    Text("hours")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                        }
                        Text("7-13 Nov 2023")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    chart
                        
                } header: {
                    sectionHeader(chartTitleText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.chart.rawValue)
                }//END OF SECTION
                .listRowSeparator(.hidden)
                
                Section {
                    if viewModel.netPayAvaliable {
                        netSalaryData
                    } // END OF IF
                     grossSalaryData
                } header: {
                    sectionHeader(salaryCalculationHeaderText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.salaryCalculation.rawValue)
                }// END OF SECTION
            } //END OF LIST
            .scrollContentBackground(.hidden)
            .navigationTitle(navTitleText)
            .toolbar { toolbar }
        } // END OF ZSTACK
    } //END OF VIEW
    
    
    func generateTotalHoursWorked() -> Int {
        viewModel.entriesForChart.map { entry in
            (entry.workTimeInSeconds + entry.overTimeInSeconds ) / 3600
        }.reduce(0, +)
    }
    
    func generateTotalHoursOvertime() -> Int {
        viewModel.entriesForChart.map { entry in
            entry.overTimeInSeconds / 3600
        }.reduce(0, +)
    }
}

//MARK: AUX. UI ELEMENTS
extension StatisticsView {
    var background: some View {
        BackgroundFactory.buildSolidColor()
    }
//TODO: FIX THE ISSUE WITH NAV LINK NOT WORKING
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink {
                            SettingsView(viewModel: SettingsViewModel(
                                dataManger: container.dataManager,
                                settingsStore: container.settingsStore))
            } label: {
                Label("Settings", systemImage: "gearshape.fill")
            } // END OF NAV LINK
            .tint(.primary)
        } // END OF TOOLBAR ITEM
    }
    
    @ViewBuilder
    func sectionHeader(_ text: String) -> some View {
        Text(text)
            .bold()
            .foregroundColor(.primary)
    }
}

//MARK: CHART VIEW BUILDERS & VARIABLES
extension StatisticsView {
    var chartTimeRangePicker: some View {
        Picker("Time range", selection: $viewModel.chartTimeRange) {
            Text("Week").tag(ChartTimeRange.week)
            Text("Month").tag(ChartTimeRange.month)
            Text("Year").tag(ChartTimeRange.year)
            Text("All").tag(ChartTimeRange.all)
        }
        .pickerStyle(.segmented)
    }
    @ViewBuilder
    var chart: some View {
            ChartFactory.buildBarChart(entries: viewModel.entriesForChart, includeRuleMark: false)
    } // END OF VAR
}

//MARK: DATA VIEW BUILDERS
extension StatisticsView {
    var netSalaryData: some View {
        ForEach(viewModel.salaryListDataNetPay, id: \.0) { data in
            generateRow(label: data.0, value: data.1)
        } // END OF FOR EACH
    }
    var grossSalaryData: some View {
        ForEach(viewModel.salaryListDataGrossPay, id: \.0) { data in
            generateRow(label: data.0, value: data.1)
        }
    }
    @ViewBuilder
    func generateRow(label: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(label)
                .foregroundStyle(.secondary)
                .font(.caption)
            Text(value)
        } // END OF HSTACK
    }
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

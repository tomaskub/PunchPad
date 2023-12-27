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
                    sectionHeader(salaryCalculationHeaderText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.salaryCalculation.rawValue)
                }// END OF SECTION
            } //END OF LIST
            .scrollContentBackground(.hidden)
            .navigationTitle(navTitleText)
            .toolbar { toolbar }
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
            ChartFactory.buildBarChart(entries: viewModel.entriesForChart,
                                       firstColor: .theme.primary,
                                       secondColor: .theme.redChart
            )
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
            TabView {
                NavigationView {
                    StatisticsView(viewModel:
                                    StatisticsViewModel(
                                        dataManager: container.dataManager,
                                        payManager: container.payManager,
                                        settingsStore: container.settingsStore)
                    )
                }
                .environmentObject(container)
                
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.xaxis")
                        .accessibilityIdentifier(ScreenIdentifier.TabBar.statistics.rawValue)
                }
            }
        }
    }
    static var previews: some View {
        ContainerView()
    }
}

//
//  HistoryView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/31/23.
//

import SwiftUI
import Charts

struct HistoryView: View {
    private typealias Identifier = ScreenIdentifier.HistoryView
    let navigationTitleText: String = "History"
    let placeholderText: String = """
                    Ooops! Something went wrong,
                    or you never recorded time...
                    """
    let headerFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var container: Container
    @StateObject private var viewModel: HistoryViewModel
    @State private var selectedEntry: Entry? = nil
    @State private var isShowingFiltering: Bool = false
    
    init(viewModel: HistoryViewModel) {
        self._viewModel = StateObject.init(wrappedValue: viewModel)        
    }
    
    var body: some View {
        ZStack {
            // BACKGROUND LAYER
            background
            // CONTENT LAYER
            List {
                makeListConent(viewModel.groupedEntries)
            } // END OF LIST
            .emptyPlaceholder(viewModel.groupedEntries) {
                emptyPlaceholderView
            }
            .scrollContentBackground(.hidden)
            .sheet(item: $selectedEntry) { entry in
                EditSheetView(viewModel: 
                                EditSheetViewModel(dataManager: container.dataManager,
                                                   settingsStore: container.settingsStore,
                                                   payService: container.payManager,
                                                   entry: entry))
            } // END OF SHEET
            .sheet(isPresented: $isShowingFiltering) {
                filteringView
                    .presentationDetents([.fraction(0.4)])
            }
        } // END OF ZSTACK
        .toolbar {
            addEntryToolbar
            filterToolbar
            navigationToolbar
        } // END OF TOOLBAR
        .navigationTitle(navigationTitleText)
        .navigationBarTitleDisplayMode(.inline)
    } // END OF BODY

    func makeSectionHeader(_ entry: Entry?) -> String {
        if let date = entry?.startDate {
            return headerFormatter.string(from: date)
        } else {
            return String()
        }
    }
    
    func makeTimeWorkedLabel(_ entry: Entry) -> String {
        let sumWorkedInSec = entry.workTimeInSeconds + entry.overTimeInSeconds
        let hours = sumWorkedInSec / 3600
        let minutes = (sumWorkedInSec % 3600) / 60
        
        let hoursString = hours > 9 ? "\(hours)" : "0\(hours)"
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        
        return "\(hoursString) hours \(minutesString) minutes"
    }
    
    func isLastEntry(_ entry: Entry) -> Bool {
        guard let lastEntry = viewModel.groupedEntries.last?.last else { return true }
        return lastEntry == entry
    }
} // END OF STRUCT

//MARK: VIEW BUILDER FUNCTIONS
extension HistoryView {
    @ViewBuilder
    func makeListConent(_ groupedEntries: [[Entry]]) -> some View {
        ForEach(groupedEntries, id: \.self) { groupEntry in
            makeListSection(groupEntry)
        }
    }
    @ViewBuilder
    func makeListSection(_ entries: [Entry]) -> some View {
        Section(makeSectionHeader(entries.first)) {
            ForEach(entries) { entry in
                VStack {
                    HistoryRowViewPrototype(startDate: entry.startDate,
                                            finishDate: entry.finishDate,
                                            workTime: entry.worktimeFraction,
                                            overTime: entry.overtimeFraction,
                                            timeWorked: makeTimeWorkedLabel(entry))
                    .accessibilityIdentifier(Identifier.entryRow.rawValue)
                    .onLongPressGesture(perform: {
                        selectedEntry = entry
                    })
                    .swipeActions {
                        makeDeleteButton(entry)
                        makeEditButton(entry)
                    } // END OF SWIPE ACTIONS
                    if isLastEntry(entry) && viewModel.isMoreEntriesAvaliable {
                        lastRow
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func makeDeleteButton(_ entry: Entry) -> some View {
        Button {
            viewModel.deleteEntry(entry: entry)
        } label: {
            Image(systemName: "xmark")
//                .foregroundColor(.red)
        } // END OF BUTTON
        .accessibilityIdentifier(Identifier.deleteEntryButton.rawValue)
        .tint(.red)
    }
    
    @ViewBuilder
    func makeEditButton(_ entry: Entry) -> some View {
        Button {
            selectedEntry = entry
        } label: {
            Image(systemName: "pencil")
//                .foregroundColor(.gray)
        } // END OF BUTTON
        .accessibilityIdentifier(Identifier.editEntryButton.rawValue)
    }
}

//MARK: VIEW COMPONENTS
extension HistoryView {
    var emptyPlaceholderView: some View {
        VStack {
            Image(systemName: "nosign")
            Text(placeholderText)
                .multilineTextAlignment(.center)
        }
    }
    
    var filteringView: some View {
        DateFilterSheetView(fromDate: $viewModel.filterFromDate,
                            toDate: $viewModel.filterToDate,
                            sortAscending: $viewModel.sortAscending)
        {
            viewModel.resetFilters()
        } confirmAction: {
            viewModel.applyFilters()
        }
    }
    
    var addEntryToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                selectedEntry = Entry()
            } label: {
                Image(systemName: "plus.circle")
            } // END OF BUTTON
            .tint(.primary)
            .accessibilityIdentifier(Identifier.addEntryButton.rawValue)
        } // END OF TOOBAR ITEM
    }
    
    var filterToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .onTapGesture {
                    isShowingFiltering.toggle()
                }
        }
    }
    
    var navigationToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink{
                SettingsView(viewModel: SettingsViewModel(
                    dataManger: container.dataManager,
                    settingsStore: container.settingsStore)
                )
            } label: {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tint(.primary)
        }
    }
    
    var lastRow: some View {
        ZStack(alignment: .center) {
            switch viewModel.paginationState {
            case .isLoading:
                ProgressView()
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
            case .idle:
                EmptyView()
            case .error:
                Text("Something went wrong")
            }
        }
        .onAppear {
            viewModel.loadMoreItems()
        }
    }
    
    var background: some View {
        BackgroundFactory.buildSolidColor()
    }
}

struct HistoryView_Previews: PreviewProvider {
    private struct ContainerView: View {
        @StateObject private var container: Container = .init()
        var body: some View {
            NavigationView {
                HistoryView(viewModel:
                                HistoryViewModel(
                                    dataManager: container.dataManager,
                                    settingsStore: container.settingsStore
                                )
                )
            }
            .environmentObject(container)
        }
    }
    static var previews: some View {
        ContainerView()
    }
}

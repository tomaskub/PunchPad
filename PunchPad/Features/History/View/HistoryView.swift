//
//  HistoryView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/31/23.
//

import SwiftUI
import Charts
import ThemeKit

struct HistoryView: View {
    private typealias Identifier = ScreenIdentifier.HistoryView
    private let navigationTitleText: String = "History"
    private let placeholderText: String = """
                    Ooops! Something went wrong,
                    or you never recorded time...
                    """
    private let deleteRowMessage: String = "Are you sure you want to delete this entry?"
    private let deleteRowIcon: String = "checkmark.circle"
    private let headerFormatter: DateFormatter = FormatterFactory.makeFullMonthYearDateFormatter()
    
    @ObservedObject private var container: Container
    @ObservedObject private var viewModel: HistoryViewModel
    @Binding private var selectedEntry: Entry?
    @Binding private var isShowingFiltering: Bool
    @State private var entryToBeDeleted: Entry?
    
    init(viewModel: HistoryViewModel, selectedEntry: Binding<Entry?>, isShowingFiltering: Binding<Bool>, container: Container) {
        self.viewModel = viewModel
        self._selectedEntry = selectedEntry
        self._isShowingFiltering = isShowingFiltering
        self.container = container
    }
}

//MARK: - Body
extension HistoryView {
    var body: some View {
        ZStack {
            background
            
            List {
                makeListConent(viewModel.groupedEntries)
                    .listRowBackground(Color.theme.white)
            }
            .listStyle(.insetGrouped)
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
            }
            .sheet(isPresented: $isShowingFiltering) {
                filteringView
                    .presentationDetents([.fraction(0.4)])
            }
        }
    }
}

//MARK: - Helper functions
private extension HistoryView {
    func makeSectionHeader(_ entry: Entry?) -> String {
        if let date = entry?.startDate {
            return headerFormatter.string(from: date)
        } else {
            return String()
        }
    }

    func isLastEntry(_ entry: Entry) -> Bool {
        guard let lastEntry = viewModel.groupedEntries.last?.last else { return true }
        return lastEntry == entry
    }
}

//MARK: - List View Builders
private extension HistoryView {
    @ViewBuilder
    func makeListConent(_ groupedEntries: [[Entry]]) -> some View {
        ForEach(groupedEntries, id: \.self) { groupEntry in
            makeListSection(groupEntry)
        }
    }
    @ViewBuilder
    func makeListSection(_ entries: [Entry]) -> some View {
        Section {
            ForEach(entries) { entry in
                if entry != entryToBeDeleted {
                    HistoryRowView(withEntry: entry)
                        .accessibilityIdentifier(Identifier.entryRow.rawValue)
                        .onTapGesture {
                            //required to scroll list and have long press gesture
                        }
                        .onLongPressGesture {
                            selectedEntry = entry
                        }
                        .swipeActions {
                            makeDeleteButton(entry)
                            makeEditButton(entry)
                        }
                } else {
                    ConfirmDeleteRowView(deleteRowMessage,
                                         iconSystemName: deleteRowIcon) {
                        viewModel.deleteEntry(entry: entry)
                    } cancelAction: {
                        withAnimation {
                            entryToBeDeleted = nil
                        }
                    }
                    .zIndex(1)
                }
                    if isLastEntry(entry) && viewModel.isMoreEntriesAvaliable {
                        lastRow
                    }
            }
        } header: {
            Text(makeSectionHeader(entries.first))
                .foregroundStyle(Color.theme.buttonLabelGray)
        }
    }
    
    @ViewBuilder
    func makeDeleteButton(_ entry: Entry) -> some View {
        Button {
            withAnimation {
                entryToBeDeleted = entry
            }
        } label: {
            Image(systemName: "xmark")
        }
        .accessibilityIdentifier(Identifier.deleteEntryButton.rawValue)
        .tint(.red)
    }
    
    @ViewBuilder
    func makeEditButton(_ entry: Entry) -> some View {
        Button {
            selectedEntry = entry
        } label: {
            Image(systemName: "pencil")
        }
        .accessibilityIdentifier(Identifier.editEntryButton.rawValue)
    }
}

//MARK: - View Components
private extension HistoryView {
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
        .listRowBackground(Color.clear)
        .onAppear {
            viewModel.loadMoreItems()
        }
    }
    
    var background: some View {
        BackgroundFactory.buildSolidColor()
    }
}

#Preview {
    struct ContainerView: View {
        @StateObject private var container: Container = .init()
        @State private var selectedEntry: Entry? = nil
        @State private var filter: Bool = false
        var body: some View {
                HistoryView(viewModel:
                                HistoryViewModel(
                                    dataManager: container.dataManager,
                                    settingsStore: container.settingsStore),
                            selectedEntry: $selectedEntry,
                            isShowingFiltering: $filter,
                            container: container
                )
                .overlay(alignment: .topTrailing) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title)
                            .foregroundColor(.theme.blackLabel)
                            .padding(.trailing)
                            .onTapGesture {
                                filter.toggle()
                            }
                }
        }
    }
    return ContainerView()
}

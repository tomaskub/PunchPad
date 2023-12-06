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
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var container: Container
    @StateObject private var viewModel: HistoryViewModel
    @State var selectedEntry: Entry? = nil
    
    init(viewModel: HistoryViewModel) {
        self._viewModel = StateObject.init(wrappedValue: viewModel)        
    }
    
    var body: some View {
        ZStack {
            // BACKGROUND LAYER
            background
            // CONTENT LAYER
            List {
                searchBar
                makeListConent(viewModel.entries)
            } // END OF LIST
            .scrollContentBackground(.hidden)
            .sheet(item: $selectedEntry) { entry in
                EditSheetView(viewModel: EditSheetViewModel(dataManager: container.dataManager,
                                                            settingsStore: container.settingsStore,
                                                            entry: entry))
            } // END OF SHEET
        } // END OF ZSTACK
        .toolbar {
            addEntryToolbar
            navigationToolbar
        } // END OF TOOLBAR
        .navigationTitle(navigationTitleText)
        .navigationBarTitleDisplayMode(.inline)
    } // END OF BODY
} // END OF STRUCT

//MARK: VIEW BUILDER FUNCTIONS
extension HistoryView {
    @ViewBuilder
    func makeListConent(_ entries: [Entry]) -> some View {
        ForEach(entries) { entry in
            HistoryRowViewPrototype(startDate: entry.startDate,
                       finishDate: entry.finishDate,
                       workTime: viewModel.convertWorkTimeToFraction(entry: entry),
                       overTime: viewModel.convertOvertimeToFraction(entry: entry),
                       timeWorked: viewModel.timeWorkedLabel(for: entry))
            .accessibilityIdentifier(Identifier.entryRow.rawValue)
            .swipeActions {
                makeDeleteButton(entry)
                makeEditButton(entry)
            } // END OF SWIPE ACTIONS
        } // END OF FOR-EACH
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
    
    var searchBar: some View {
        Section {
            HStack {
                TextField("", text: .constant(String()), prompt: Text("Search"))
                Image(systemName: "calendar")
            }
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

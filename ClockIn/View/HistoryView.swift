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
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var container: Container
    @StateObject private var viewModel: HistoryViewModel
    @State var selectedEntry: Entry? = nil
    
    init(viewModel: HistoryViewModel) {
        self._viewModel = StateObject.init(wrappedValue: viewModel)        
    }
    
    //unused for now - have to implement
    /*
     @AppStorage("detail_display_mode") var detailDisplayMode: String = HistoryRow.DetailDisplayType.circleDisplay.rawValue
     */
    var body: some View {
        ZStack {
            // BACKGROUND LAYER
            BackgroundFactory.buildGradient(colorScheme: colorScheme)
            // CONTENT LAYER
            List {
                ForEach(viewModel.entries) { entry in
                    HistoryRow(startDate: entry.startDate,
                               finishDate: entry.finishDate,
                               workTime: viewModel.convertWorkTimeToFraction(entry: entry),
                               overTime: viewModel.convertOvertimeToFraction(entry: entry),
                               timeWorked: viewModel.timeWorkedLabel(for: entry),
                               detailType: .circleDisplay)
                    .accessibilityIdentifier(Identifier.entryRow.rawValue)
                    .swipeActions {
                        Button {
                            viewModel.deleteEntry(entry: entry)
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        } // END OF BUTTON
                        .accessibilityIdentifier(Identifier.deleteEntryButton.rawValue)
                        .tint(.red)
                        Button {
                            selectedEntry = entry
                        } label: {
                            Image(systemName: "pencil")
                        } // END OF BUTTON
                        .accessibilityIdentifier(Identifier.editEntryButton.rawValue)
                    } // END OF SWIPE ACTIONS
                } // END OF FOR-EACH
            } // END OF LIST
            .scrollContentBackground(.hidden)
            .sheet(item: $selectedEntry) { entry in
                EditSheetView(viewModel: EditSheetViewModel(dataManager: container.dataManager,
                                                            settingsStore: container.settingsStore,
                                                            entry: entry))
            } // END OF SHEET
        } // END OF ZSTACK
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    selectedEntry = Entry()
                } label: {
                    Image(systemName: "plus.circle")
                } // END OF BUTTON
                .accessibilityIdentifier(Identifier.addEntryButton.rawValue)
            } // END OF TOOBAR ITEM
        } // END OF TOOLBAR
        .navigationTitle("History")
    } // END OF BODY
} // END OF STRUCT


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

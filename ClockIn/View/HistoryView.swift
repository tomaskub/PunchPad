//
//  HistoryView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/31/23.
//

import SwiftUI
import Charts

struct HistoryView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = HistoryViewModel()
    @State var selectedEntry: Entry? = nil
    
    //unused for now - have to implement
    /*
     @AppStorage("detail_display_mode") var detailDisplayMode: String = HistoryRow.DetailDisplayType.circleDisplay.rawValue
     */
    
    
    
    var body: some View {
        ZStack {
            //background layer
            LinearGradient(colors: [ colorScheme == .light ? .white : .black, .blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            //Content layer
            List {
                ForEach(viewModel.entries) { entry in
                    HistoryRow(startDate: entry.startDate,
                               finishDate: entry.finishDate,
                               workTime: viewModel.convertWorkTimeToFraction(entry: entry),
                               overTime: viewModel.convertOvertimeToFraction(entry: entry),
                               timeWorked: viewModel.timeWorkedLabel(for: entry),
                               detailType: .circleDisplay)
                    .swipeActions {
                        Button {
                            //run delete action
                            viewModel.deleteEntry(entry: entry)
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        }
                        .tint(.red)
                        Button {
                            //run editing sheet
                            selectedEntry = entry
                        } label: {
                            Image(systemName: "pencil")
                        }
//                        .tint(.blue)
                    }
                }
                .sheet(item: $selectedEntry) { entry in
                    
                        EditSheetView(viewModel: EditSheetViewModel(entry: entry))
                    
                }
            }
            .scrollContentBackground(.hidden)
            
        }
        
        //Toolbars
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    selectedEntry = Entry()
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
        }
        .navigationTitle("History")
        
    }
    
}


struct HistoryView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            HistoryView(viewModel: HistoryViewModel(dataManager: DataManager.preview, overrideUD: true))
        }
    }
}

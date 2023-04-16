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
                }
                 
            }
            .scrollContentBackground(.hidden)
            
        }
        //Toolbars
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("Edit")
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

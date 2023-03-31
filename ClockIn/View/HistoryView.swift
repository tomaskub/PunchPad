//
//  HistoryView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/31/23.
//

import SwiftUI

struct HistoryView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var coreDataVM: CoreDataViewModel
    @AppStorage("detail_display_mode") var detailDisplayMode: String = HistoryRow.DetailDisplayType.circleDisplay.rawValue
    
    var body: some View {
        ZStack {
            //background layer
            LinearGradient(colors: [ colorScheme == .light ? .white : .black, .blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            List {
                ForEach(coreDataVM.savedEntries, id: \.self) { entry in
                    HistoryRow(date: entry.startDate, startDate: entry.startDate, finishDate: entry.finishDate, overTime: entry.overtime, detailType: .circleDisplay)
                }
            }
            .scrollContentBackground(.hidden)
         
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    
    static var previews: some View {
        HistoryView()
            .environmentObject(CoreDataViewModel())
    }
}

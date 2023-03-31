//
//  HistoryRow.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/31/23.
//

import SwiftUI

struct HistoryRow: View {
    
    enum DetailDisplayType: String {
        case circleDisplay = "circleDisplay"
        case barDisplay = "barDisplay"
    }
    
    var date: Date
    var startDate: Date
    var finishDate: Date
    var overTime: Float
    
    @State var isShowingDetails: Bool = false 
    @State var detailType: DetailDisplayType
    
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text(date.formatted(date: .long, time: .omitted))
                Spacer()
                Text("worked: 08:30")
            }
//            .padding(.vertical)
            if isShowingDetails {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Start time:")
                        Text("Finish time:")
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(startDate.formatted(date: .omitted, time: .shortened))
                        Text(finishDate.formatted(date: .omitted, time: .shortened))
                    }
                    Spacer()
                    switch detailType {
                    case .circleDisplay:
                        ZStack {
                            RingView(progress: .constant(1), ringColor: .blue, ringWidth: 5, displayPointer: false)
                            RingView(progress: .constant(CGFloat(overTime)/5), ringColor: .green, ringWidth: 5, displayPointer: false)
                                .padding(8)
                        }
                        .frame(width: 80, height: 80)
                    case .barDisplay:
                        GeometryReader { proxy in
                            VStack(alignment: .leading) {
                                Capsule()
                                    .fill(.blue)
                                    
                                    .frame(width: proxy.size.width - 10, height: 10)
                                Capsule()
                                    .fill(.green)
                                    .frame(width: (proxy.size.width - 10) * CGFloat(overTime / 5), height: 10)
                            }
                            .padding(.top)
                            .padding(.leading)
                        }
                    }
                    
                }
            }
        }
        .padding(.vertical)
        .onTapGesture {
            isShowingDetails.toggle()
        }
    }
}

struct HistoryRow_Previews: PreviewProvider {
    
    static var previews: some View {
        List {
            HistoryRow(
                date: Date(),
                startDate: Calendar.current.date(byAdding: .hour, value: -7 , to: Date())!,
                finishDate: Calendar.current.date(byAdding: .hour, value: 2 , to: Date())!,
                overTime: 1,
                detailType: .circleDisplay)
            HistoryRow(
                date: Date(),
                startDate: Calendar.current.date(byAdding: .hour, value: -7 , to: Date())!,
                finishDate: Calendar.current.date(byAdding: .hour, value: 2 , to: Date())!,
                overTime: 1,
                detailType: .barDisplay)
            
        }
    }
}

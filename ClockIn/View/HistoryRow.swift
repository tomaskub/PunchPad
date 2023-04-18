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
    
    
    var startDate: Date
    var finishDate: Date
    var workTime: CGFloat
    var overTime: CGFloat
    var timeWorked: String
    
    @State var isShowingDetails: Bool = false
    @State var detailType: DetailDisplayType
    
    var body: some View {
        VStack(alignment: .leading){
            
            HStack {
                Text(startDate.formatted(date: .long, time: .omitted))
                Spacer()
                Text(timeWorked)
            }
            
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
                            
                            RingView(progress: .constant(workTime), ringColor: .blue, ringWidth: 5, displayPointer: false)
                            
                            RingView(progress: .constant(overTime), ringColor: .green, ringWidth: 5, displayPointer: false)
                                .padding(8)
                        }
                        .frame(width: 80, height: 80)
                    
                    case .barDisplay:
                        
                        GeometryReader { proxy in
                            
                            VStack(alignment: .leading) {
                                
                                Capsule()
                                    .fill(.blue)
                                    .frame(width: (proxy.size.width - 10) * workTime, height: 10)
                                
                                Capsule()
                                    .fill(.green)
                                    .frame(width: (proxy.size.width - 10) * overTime, height: 10)
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
            withAnimation(.spring()) {
                isShowingDetails.toggle()
            }
            
        }
    }
}

struct HistoryRow_Previews: PreviewProvider {
    
    static var previews: some View {
        List {
            HistoryRow(
                startDate: Calendar.current.date(byAdding: .hour, value: -7 , to: Date())!,
                finishDate: Calendar.current.date(byAdding: .hour, value: 2 , to: Date())!,
                workTime: 1,
                overTime: 0.5,
                timeWorked: "08:30",
                detailType: .circleDisplay
            )
            HistoryRow(
                
                startDate: Calendar.current.date(byAdding: .hour, value: -7 , to: Date())!,
                finishDate: Calendar.current.date(byAdding: .hour, value: 2 , to: Date())!,
                workTime: 1,
                overTime: 0.3,
                timeWorked: "09:00",
                isShowingDetails: true,
                detailType: .barDisplay
            )
            
        }
    }
}

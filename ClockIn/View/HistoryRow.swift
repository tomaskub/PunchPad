//
//  HistoryRow.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/31/23.
//

import SwiftUI

struct HistoryRowViewPrototype: View {
    var startDate: Date
    var finishDate: Date
    var workTime: CGFloat
    var overTime: CGFloat
    var timeWorked: String
    @State private var showDetails: Bool = false
    var body: some View {
        Grid(alignment: .leading) {
            GridRow {
                Text(startDate.formatted(date: .abbreviated, time: .omitted).uppercased())
                Text(timeWorked)
            }
            if showDetails {
                GridRow {
                    Text("\(startDate.formatted(date: .omitted, time: .shortened)) - \(finishDate.formatted(date: .omitted, time: .shortened))")
                    GeometryReader { proxy in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(.blue)
                                .frame(width: (proxy.size.width - 10) * workTime / 2,
                                       height: proxy.size.height/2)
                            Rectangle()
                                .fill(.orange)
                                .frame(width: (proxy.size.width - 10) * overTime / 2,
                                       height: proxy.size.height/2)
                        } // END OF VSTACK
                        .position(x: proxy.size.width/2,
                                  y: proxy.size.height/2)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                showDetails.toggle()
            }
        }
        .padding(.vertical)
    }
}
struct HistoryRow: View {
    
    private typealias Identifier = ScreenIdentifier.HistoryRowView
    enum DetailDisplayType: String {
        case circleDisplay
        case barDisplay
        case singleBarDisplay
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
                    .accessibilityIdentifier(Identifier.Label.dateLabel.rawValue)
                Spacer()
                Text(timeWorked)
                    .accessibilityIdentifier(Identifier.Label.timeWorkedLabel.rawValue)
            } // END OF H STACK
            
            if isShowingDetails {
                HStack(alignment: .center) {
                    detailView
                    Spacer()
                    makeDetailDisplay(detailType)
                } // END OF HSTACK
            } // END OF IF
        } // END OF VSTACK
        .padding(.vertical)
        .onTapGesture {
            withAnimation(.spring()) {
                isShowingDetails.toggle()
            } // END OF ANIMATION
        } // END OF TAP GESTURE
    } // END OF BODY
    
    var detailView: some View {
        Group {
            VStack(alignment: .leading, spacing: 5) {
                Text("Start time:")
                Text("Finish time:")
            } // END OF VSTACK
            VStack(alignment: .leading, spacing: 5) {
                Text(startDate.formatted(date: .omitted, time: .shortened))
                    .accessibilityIdentifier(Identifier.Label.startTimeValueLabel.rawValue)
                Text(finishDate.formatted(date: .omitted, time: .shortened))
                    .accessibilityIdentifier(Identifier.Label.finishTimeValueLabel.rawValue)
            } // END OF VSTACK
        } // END OF GROUP
    } // END OF VAR
    
    @ViewBuilder
    private func makeDetailDisplay(_ detailType: DetailDisplayType) -> some View {
        switch detailType {
        case .circleDisplay:
            ZStack {
                RingView(startPoint: .constant(0), endPoint: .constant(workTime), ringColor: .blue, ringWidth: 5, displayPointer: false)
                RingView(startPoint: .constant(0), endPoint: .constant(overTime), ringColor: .green, ringWidth: 5, displayPointer: false)
                    .padding(8)
            } // END OF ZSTACK
            .accessibilityIdentifier(Identifier.DetailView.circleDetail.rawValue)
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
                } // END OF VSTACK
                .padding(.top)
                .padding(.leading)
            } // END OF GEO READER
        case .singleBarDisplay:
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(.blue)
                        .frame(width: (proxy.size.width - 10) * workTime / 2, height: 24)
                    Rectangle()
                        .fill(.green)
                        .frame(width: (proxy.size.width - 10) * overTime / 2, height: 24)
                } // END OF VSTACK
                .padding(.top)
                .padding(.leading)
            } // END OF GEO READER
        } // END OF SWITCH
    } // END OF FUNC
} // END OF STRUCT

struct HistoryRow_Previews: PreviewProvider {
    
    static var previews: some View {
        List {
            HistoryRowViewPrototype(
                startDate: Calendar.current.date(byAdding: .hour, value: -7 , to: Date())!,
                finishDate: Calendar.current.date(byAdding: .hour, value: 2 , to: Date())!,
                workTime: 1,
                overTime: 0.5,
                timeWorked: "8 hours 30 minutes"
            )
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
            HistoryRow(
                startDate: Calendar.current.date(byAdding: .hour, value: -7 , to: Date())!,
                finishDate: Calendar.current.date(byAdding: .hour, value: 2 , to: Date())!,
                workTime: 1,
                overTime: 0.3,
                timeWorked: "09:00",
                isShowingDetails: true,
                detailType: .singleBarDisplay
            )
        } // END OF LIST
    } // END OF PREVIEW
} // END OF STRUCT

//
//  TimeIntervalPicker.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 19/12/2023.
//

import SwiftUI

struct TimeIntervalPicker: View {
    let buttonLabelText: String
    @Binding var hourComponent: Int
    @Binding var minuteComponent: Int
    @State private var isShowingPickers: Bool = false
    
    var body: some View {
        Button {
            isShowingPickers.toggle()
        } label: {
            Text(buttonLabelText)
                .foregroundColor(.black)
                .padding(.vertical, 8)
                .padding(.horizontal,14)
                .background(.gray.opacity(0.15))
                .cornerRadius(10)
        }
        .popover(isPresented: $isShowingPickers) {
            HStack {
                Picker(selection: $hourComponent) {
                    ForEach(0..<24, id: \.self) { i in
                        Text("\(i)").tag(i)
                    }
                } label: {
                    EmptyView()
                }
                .frame(width: 100)
                .pickerStyle(.wheel)
                Picker(selection: $minuteComponent) {
                    ForEach(0..<60, id: \.self) { i in
                        Text("\(i)").tag(i)
                    }
                } label: {
                    EmptyView()
                }
                .frame(width: 100)
                .pickerStyle(.wheel)
            }
            .presentationCompactAdaptation(.popover)
        }
    }
}


#Preview {
    TimeIntervalPicker(buttonLabelText: "01:30",
                       hourComponent: .constant(1),
                       minuteComponent: .constant(15)
    )
}

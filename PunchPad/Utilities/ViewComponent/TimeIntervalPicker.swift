//
//  TimeIntervalPicker.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 19/12/2023.
//

import SwiftUI

struct TimeIntervalPicker: View {
    let buttonLabelText: String
    @State private var isShowingPickers: Bool = false
    @Binding var value: TimeInterval
    
    var hourComponent: Binding<Int> {
        Binding(get: {
            Int(self.value) / 3600
        }, set: { hours in
            self.value = TimeInterval(hours * 3600 + self.minuteComponent.wrappedValue * 60)
        })
    }
    
    var minuteComponent: Binding<Int> {
        Binding(get: {
            Int(self.value) % 3600 / 60
        }, set: { minutes in
            self.value = TimeInterval(self.hourComponent.wrappedValue * 3600 + minutes * 60)
        })
    }
    
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
                Picker(selection: hourComponent) {
                    ForEach(0..<24, id: \.self) { i in
                        Text("\(i)").tag(i)
                    }
                } label: {
                    EmptyView()
                }
                .frame(width: 100)
                .pickerStyle(.wheel)
                Picker(selection: minuteComponent) {
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
                       value: .constant(TimeInterval(integerLiteral: 1800 * 3)
                                       )
    )
}

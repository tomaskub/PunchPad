//
//  TimeIntervalPicker.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 19/12/2023.
//

import SwiftUI

public struct TimeIntervalPicker: View {
    let hoursInDay = 24
    let minutesInHour = 60
    let secondsInHour = 3600
    let secondsInMinute = 60
    let buttonLabelText: String
    @State private var isShowingPickers: Bool = false
    @Binding var value: TimeInterval
    
    public init(buttonLabelText: String, value: Binding<TimeInterval>) {
        self.buttonLabelText = buttonLabelText
        self._value = value
    }
    
    var hourComponent: Binding<Int> {
        Binding(get: {
            Int(self.value) / secondsInHour
        }, set: { hours in
            self.value = TimeInterval(hours * secondsInHour + self.minuteComponent.wrappedValue * secondsInMinute)
        })
    }
    
    var minuteComponent: Binding<Int> {
        Binding(get: {
            Int(self.value) % secondsInHour / secondsInMinute
        }, set: { minutes in
            self.value = TimeInterval(self.hourComponent.wrappedValue * secondsInHour + minutes * secondsInMinute)
        })
    }
    
    public var body: some View {
        Button {
            isShowingPickers.toggle()
        } label: {
            Text(buttonLabelText)
                .foregroundColor(.black)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(.gray.opacity(0.15))
                .cornerRadius(10)
        }
        .popover(isPresented: $isShowingPickers) {
            HStack {
                Picker(selection: hourComponent) {
                    ForEach(0..<hoursInDay, id: \.self) { hour in
                        Text("\(hour)").tag(hour)
                    }
                } label: {
                    EmptyView()
                }
                .frame(width: 100)
                .pickerStyle(.wheel)
                Picker(selection: minuteComponent) {
                    ForEach(0..<minutesInHour, id: \.self) { minute in
                        Text("\(minute)").tag(minute)
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

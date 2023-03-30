//
//  SettingsView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var timer: TimerModel
    @AppStorage("isLoggingOverTime") var isLoggingOverTime: Bool = true
    
    @State var isShowingTimerEditing: Bool = true
    
    var body: some View {
        ZStack{
            //BACKGROUND
            LinearGradient(colors: [ colorScheme == .light ? .white : .black, .blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            
            //CONTENT
            List {
                
                Section("Timer Settings") {
                    
                    HStack {
                        Text("Set timer length")
                        Spacer()
                        Image(systemName: isShowingTimerEditing ? "chevron.up" : "chevron.down")
                    }
                    .onTapGesture {
                        isShowingTimerEditing.toggle()
                    }
                    
                    if isShowingTimerEditing {
                        timePickers
                    }
                    
                    Toggle(isOn: .constant(true)) {
                        Text("Send notification on finish")
                    }
                }
                Section("Overtime") {
                    Toggle(isOn: $isLoggingOverTime) {
                        Text("Keep loging overtime")
                    }
                    
                }
                
                Section("Appearance") {
                    VStack{
                        Text("Color scheme")
                        Picker("appearance", selection: .constant(1)) {
                            Text("System")
                            Text("Dark")
                            Text("Light")
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
            }
            .foregroundColor(.primary)
//            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
    }
    var timePickers: some View {
        HStack {
            VStack {
                Text("Hours")
                Picker("hours", selection: $timer.hours) {
                    ForEach(0..<25) { i in
                        Text("\(i)").tag(i)
                            .foregroundColor(.black)
                    }
                }
                .pickerStyle(.wheel)
            }
            VStack {
                Text("Minutes")
                
                Picker("minutes", selection: $timer.minutes) {
                    ForEach(0..<60) { i in
                        Text("\(i)").tag(i)
                            .foregroundColor(.black)
                    }
                }
                .pickerStyle(.wheel)
            }
            VStack {
                Text("Seconds")
                
                Picker("seconds", selection: $timer.seconds) {
                    ForEach(0..<60) { i in
                        Text("\(i)").tag(i)
                            .foregroundColor(.black)
                    }
                }
                .pickerStyle(.wheel)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(TimerModel())
        SettingsView().environment(\.colorScheme, .dark)
            .environmentObject(TimerModel())
    }
        
}

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
    @EnvironmentObject var coreDataVM: CoreDataViewModel
    
    @AppStorage("isLoggingOverTime") var isLoggingOverTime: Bool = true
    @AppStorage("colorScheme") var preferredColorScheme: String = "system"
    @AppStorage("overtimeMaximum") var maximumOvertimeAllowed: Double = 5.0
    
    @State var isShowingTimerEditing: Bool = false 
    @State var isShowingOvertimeMaximumEditing: Bool = false
    
    
    
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
                        withAnimation(.spring()) {
                            isShowingTimerEditing.toggle()
                        }
                        
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
                    
                    HStack {
                        Text("Maximum overtime allowed")
                        Spacer()
                        Image(systemName: isShowingOvertimeMaximumEditing ? "chevron.up" : "chevron.down")
                    }
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isShowingOvertimeMaximumEditing.toggle()
                        }
                        
                    }
                    
                    if isShowingOvertimeMaximumEditing {
                        timePickers
                    }
                }
                
                Section("User data") {
                    HStack {
                        Text("Clear all saved data")
                            Spacer()
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .onTapGesture {
                        coreDataVM.deleteData()
                    }
                    HStack {
                        Text("Reset preferences")
                        Spacer()
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.red)
                    }
                    .onTapGesture {
                        resetUserSettings()
                    }
                }
                
                Section("Appearance") {
                    VStack{
                        Text("Color scheme")
                        Picker("appearance", selection: $preferredColorScheme) {
                            Text("System").tag("system")
                            Text("Dark").tag("dark")
                            Text("Light").tag("light")
                        }
                        .pickerStyle(.segmented)
                    }
                    
                }
                
            }
            .foregroundColor(.primary)
            .scrollContentBackground(.hidden)
        }
    }
    func resetUserSettings() {
        
    }
    var timePickers: some View {
        HStack {
            VStack {
                Text("Hours")
                Picker("hours", selection: $timer.hours) {
                    ForEach(0..<25) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .pickerStyle(.wheel)
            }
            VStack {
                Text("Minutes")
                
                Picker("minutes", selection: $timer.minutes) {
                    ForEach(0..<60) { i in
                        Text("\(i)").tag(i)
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

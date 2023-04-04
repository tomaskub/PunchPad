//
//  SettingsView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = SettingsViewModel()
    
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
                        Image(systemName: viewModel.isShowingWorkTimeEditor ? "chevron.up" : "chevron.down")
                    }
                    .onTapGesture {
                        withAnimation(.spring()) {
                            viewModel.isShowingWorkTimeEditor.toggle()
                        }
                        
                    }
                    
                    if viewModel.isShowingWorkTimeEditor {
                        timePickers
                    }
                    
                    Toggle(isOn: $viewModel.isSendingNotifications) {
                        Text("Send notification on finish")
                    }
                }
                Section("Overtime") {
                    
                    Toggle(isOn: $viewModel.isLoggingOverTime) {
                        Text("Keep loging overtime")
                    }
                    
                    HStack {
                        Text("Maximum overtime allowed")
                        Spacer()
                        Image(systemName: viewModel.isShowingOverTimeEditor ? "chevron.up" : "chevron.down")
                    }
                    .onTapGesture {
                        withAnimation(.spring()) {
                            viewModel.isShowingOverTimeEditor.toggle()
                        }
                        
                    }
                    
                    if viewModel.isShowingOverTimeEditor {
                        overTimePickers
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
                        viewModel.deleteAllData()
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
                        Picker("appearance", selection: $viewModel.preferredColorScheme) {
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
                Picker("hours", selection: $viewModel.timerHours) {
                    ForEach(0..<25) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .pickerStyle(.wheel)
            }
            VStack {
                Text("Minutes")
                
                Picker("minutes", selection: $viewModel.timerMinutes) {
                    ForEach(0..<60) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .pickerStyle(.wheel)
            }
        }
    }
    var overTimePickers: some View {
        HStack {
            VStack {
                Text("Hours")
                Picker("hours", selection: $viewModel.overtimeHours) {
                    ForEach(0..<25) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .pickerStyle(.wheel)
            }
            VStack {
                Text("Minutes")
                
                Picker("minutes", selection: $viewModel.overtimeMinutes) {
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
            
        SettingsView().environment(\.colorScheme, .dark)
            .environmentObject(TimerModel())
    }
        
}

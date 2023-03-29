//
//  SettingsView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack{
            //BACKGROUND
            LinearGradient(colors: [ colorScheme == .light ? .white : .black, .blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            
            //CONTENT
            List {
                
                Section("Timer Settings") {
                    
                    Text("Set timer length")
                    
                    Toggle(isOn: .constant(true)) {
                        Text("Send notification on finish")
                    }
                }
                Section("Overtime") {
                    Text("Keep loging overtime")
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
        SettingsView().environment(\.colorScheme, .dark)
    }
}

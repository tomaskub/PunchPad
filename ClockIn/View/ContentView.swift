//
//  ContentView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/27/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    
    @State var timerHours: Int = 8
    @State var timerMinutes: Int = 30
    
    var body: some View {
        NavigationView {
            ZStack {
                
                //background layer
                LinearGradient(colors: [ colorScheme == .light ? .white : .black, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                //Foreground layer
                VStack {
                    Button {
                        timerHours -= 1
                    } label: {
                        Text("\(timerHours) : \(timerMinutes)")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .frame(width: 200,height: 200)
                            .background {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [.blue,.black],
                                            center: .center,
                                            startRadius: 50,
                                            endRadius: 200))
                            }
                    }
                    .onLongPressGesture {
                        //activate editing the time
                    }

                }
                
            }
            .navigationTitle("ClockIn")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    Text("History screen")
                } label: {
                        Text("History")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        Text("Settings")
                    } label: {
                        Text("Settings")
                    }
                }
            }
            
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  Home.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI

struct Home: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var timer: TimerModel
    
    var body: some View {
        NavigationView {
            ZStack {
                
                //background layer
                LinearGradient(colors: [ colorScheme == .light ? .white : .black, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                //Foreground layer
                GeometryReader { proxy in
                    VStack {
                        ZStack {
                            Circle()
                                .trim(from: 0, to: timer.progress)
                                .stroke(Color.purple.opacity(0.7), lineWidth: 10)
                                .rotationEffect(.init(degrees: -90))
                                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                                    if timer.isStarted {
                                        timer.updateTimer()
                                    }
                                }
                            Text("\(timer.seconds):")
                        }
                        Spacer()
                        Button(action: timer.startTimer) {
                            Image(systemName: "play.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(60)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .padding()
                
                
                
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

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TimerModel())
    }
}

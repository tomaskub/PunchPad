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
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.3))
                                .padding()
                            
                            hourRing
                            
                            Text("\(timer.timerStringValue)")
                        }
                        .padding(60)
                        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                            if timer.isStarted {
                                timer.updateTimer()
                            }
                        }
                        Spacer()
                        Button(action:
                                timer.isStarted ? timer.stopTimer : timer.startTimer) {
                            Image(systemName: timer.isStarted ? "pause.fill" : "play.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        HStack {
                            
                            Picker("hours", selection: $timer.hours) {
                                ForEach(0..<25) { i in
                                    Text("\(i)").tag(i)
                                        .foregroundColor(.black)
                                }
                            }
                            .pickerStyle(.wheel)
                            Picker("minutes", selection: $timer.minutes) {
                                ForEach(0..<60) { i in
                                    Text("\(i)").tag(i)
                                        .foregroundColor(.black)
                                }
                            }
                            .pickerStyle(.wheel)
                            Picker("seconds", selection: $timer.seconds) {
                                ForEach(0..<60) { i in
                                    Text("\(i)").tag(i)
                                        .foregroundColor(.black)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .cornerRadius(10)
                    }
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
                        SettingsView().navigationTitle("Settings")
                    } label: {
                        Text("Settings")
                    }
                }
            }
            
            
        }
    }
    
    var secondRing: some View {
        Circle()
            .trim(from: (timer.secondProgress) >= 0.05 ? timer.secondProgress - 0.05 : 0, to: timer.secondProgress)
            .stroke(Color.purple.opacity(0.7), lineWidth: 10)
            .rotationEffect(.init(degrees: -90))
//            .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
//                if timer.isStarted {
//                    timer.updateTimer()
//                }
//            }
    }
    var minuteRing: some View {
        Circle()
            .trim(from: 0, to: timer.minuteProgress)
            .stroke(Color.pink.opacity(0.7), lineWidth: 10)
            .rotationEffect(.init(degrees: -90))
            .padding(-20)
//            .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
//                if timer.isStarted {
//                    timer.updateTimer()
//                }
//            }
    }
    var hourRing: some View {
        Circle()
            .trim(from: 0, to: timer.progress)
            .stroke(Color.black.opacity(0.7), lineWidth: 10)
            .rotationEffect(.init(degrees: -90))
            .padding(-40)
            
    }
    
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TimerModel())
    }
}

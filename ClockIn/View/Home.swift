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
    
    @State var isShowingTimePicker: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                
                
                //background layer
                LinearGradient(colors: [ colorScheme == .light ? .white : .black, .blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                //Foreground layer
                Button(action:
                        timer.isStarted ? timer.stopTimer : timer.startTimer) {
                    ZStack {
                        
                        Circle()
                            .fill(.blue.opacity(0.5))
                            .padding()
                        Text("\(timer.timerStringValue)")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .padding()
                            .background(.gray.opacity(0.5))
                            .cornerRadius(10)
                            .onLongPressGesture(perform: {
                                withAnimation(.easeInOut) {
                                    isShowingTimePicker.toggle()
                                }
                            })
                    }
                }
                        .padding(60)
                        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                            if timer.isStarted {
                                timer.updateTimer()
                            }
                        }
                
                RingView(progress: $timer.progress, ringColor: .primary, pointColor: colorScheme == .light ? .white : .black)
                    .padding(60)
                
                if timer.overtimeProgress > 0 {
                    RingView(progress: $timer.overtimeProgress, ringColor: .green, pointColor: .white, ringWidth: 5, startigPoint: 0.023)
                        .padding(60)
                }
                
                if isShowingTimePicker {
                    VStack {
                        Spacer()
                        timePickers
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
                        SettingsView().navigationTitle("Settings")
                    } label: {
                        Text("Settings")
                    }
                }
            }
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
        .padding(.top)
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(10)
    }
    
    var secondRing: some View {
        Circle()
            .trim(from: (timer.secondProgress) >= 0.05 ? timer.secondProgress - 0.05 : 0, to: timer.secondProgress)
            .stroke(Color.purple.opacity(0.7), lineWidth: 10)
            .rotationEffect(.init(degrees: -90))

    }
    
    var minuteRing: some View {
        Circle()
            .trim(from: 0, to: timer.minuteProgress)
            .stroke(Color.pink.opacity(0.7), lineWidth: 10)
            .rotationEffect(.init(degrees: -90))
            .padding(-20)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TimerModel())
    }
}

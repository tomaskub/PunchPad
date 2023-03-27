//
//  ContentView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/27/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var timer: String = "8:00"
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [.blue, colorScheme == .light ? .white : .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                VStack {
                    Button {
                        //start timer here
                    } label: {
                        Text(timer)
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .background {
                                Circle()
                                    .frame(width: 200,height: 200)
                            }
                    }

                }
                
            }
            .navigationTitle("ClockIn")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    Text("History screen")
                } label: {
                        Text("History")
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

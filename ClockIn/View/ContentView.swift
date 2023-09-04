//
//  ContentView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/27/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timerModel: TimerModel
    @AppStorage(K.UserDefaultsKeys.isRunFirstTime) var isRunFirstTime: Bool = true
    var body: some View {
        Home()
            .environmentObject(timerModel)
            .fullScreenCover(isPresented: $isRunFirstTime, onDismiss: {
                isRunFirstTime = false
            }) {
                OnboardingView()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(TimerModel())
    }
}

//
//  ContentView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/27/23.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage(K.UserDefaultsKeys.isRunFirstTime) var isRunFirstTime: Bool = true
    @EnvironmentObject var container: Container
    
    var body: some View {
        NavigationView {
            Home(viewModel: HomeViewModel(dataManager: container.dataManager,
                                       timerProvider: container.timerProvider)
            )
        }
            .fullScreenCover(isPresented: $isRunFirstTime, onDismiss: {
                isRunFirstTime = false
            }) {
                OnboardingView()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Container())
    }
}

//
//  ContentView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/27/23.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var container: Container
    
    var body: some View {
        NavigationView {
            HomeView(viewModel: HomeViewModel(dataManager: container.dataManager,
                                       timerProvider: container.timerProvider)
            )
        }
        .fullScreenCover(isPresented: $container.settingsStore.isRunFirstTime, onDismiss: {
            container.settingsStore.isRunFirstTime = false
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

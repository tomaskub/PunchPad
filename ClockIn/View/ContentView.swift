//
//  ContentView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/27/23.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var container: Container
    @AppStorage(SettingsStore.SettingKey.isRunFirstTime.rawValue) var isRunFirstTime: Bool = true 
    
    var body: some View {
        NavigationView {
            HomeView(viewModel: HomeViewModel(dataManager: container.dataManager,
                                       timerProvider: container.timerProvider)
            )
        }
        .fullScreenCover(isPresented: $isRunFirstTime, onDismiss: {
            isRunFirstTime = false
            }) {
                OnboardingView(viewModel: OnboardingViewModel(settingsStore: container.settingsStore))
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Container())
    }
}

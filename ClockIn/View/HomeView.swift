//
//  Home.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI

struct HomeView: View {
    private typealias Identifier = ScreenIdentifier.HomeView
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject private var container: Container
    
    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
            ZStack {
                //BACKGROUND LAYER
                background
                // CONTENT
                mainButton
                worktimeProgressRing
                if viewModel.overtimeProgress > 0 {
                    overtimeProgressRing
                }
                controlButtons
                    .offset(y: 200)
            } // END OF ZSTACK
            .navigationTitle("ClockIn")
            .toolbar {
                toolbar
            } // END OF TOOLBAR
    } // END OF BODY
    
    var background: some View {
        BackgroundFactory.buildGradient(colorScheme: colorScheme)
    }
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink {
                SettingsView(viewModel:
                                SettingsViewModel(
                                    dataManger: container.dataManager,
                                    settingsStore: container.settingsStore))
            } label: {
                Label("Settings", systemImage: "gearshape.fill")
            } // END OF NAV LINK
            .accessibilityIdentifier(Identifier.settingNavigationButton.rawValue)
        } // END OF TOOLBAR ITEM
    }
    var controlButtons: some View {
//        if viewModel.isStarted {
            Button {
                viewModel.isRunning.toggle()
            } label: {
                Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                    .resizable()
            } // END OF BUTTON
            .accessibilityIdentifier(Identifier.resumePauseButton.rawValue)
            .accentColor(.primary)
            .frame(width: 50, height: 50)
//        } // END OF IF
    }
    var mainButton: some View {
        Button(action:
                viewModel.isStarted ? viewModel.stopTimer : viewModel.startTimer) {
            ZStack(alignment: .center) {
                Circle()
                    .fill(.blue.opacity(0.5))
                    .padding()
                Text("\(viewModel.timerStringValue)")
                    .accessibilityIdentifier(Identifier.timerLabel.rawValue)
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                    .background(.gray.opacity(0.5))
                    .cornerRadius(10)
            } // END OF ZSTACK
        } // END OF BUTTON
                .accessibilityIdentifier(Identifier.startStopButton.rawValue)
                .padding(60)
    }
    var worktimeProgressRing: some View {
        return RingView(progress: $viewModel.progress,
                 ringColor: .primary,
                 pointColor: colorScheme == .light ? .white : .black)
            .frame(width: UIScreen.main.bounds.size.width-120,
                   height: UIScreen.main.bounds.size.width-120)
    }
    var overtimeProgressRing: some View {
            RingView(progress: $viewModel.overtimeProgress,
                     ringColor: .green,
                     pointColor: .white,
                     ringWidth: 5,
                     startigPoint: 0.023)
                .frame(width: UIScreen.main.bounds.size.width-120, height: UIScreen.main.bounds.size.width-120)
    }
} // END OF VIEW

struct Home_Previews: PreviewProvider {
    private struct ContainerView: View {
        @StateObject private var container: Container = .init()
        var body: some View {
            NavigationView {
                HomeView(viewModel: HomeViewModel(dataManager: container.dataManager,
                                                  settingsStore: container.settingsStore,
                                                  timerProvider: container.timerProvider))
            }
            .environmentObject(Container())
        }
    }
    static var previews: some View {
        ContainerView()
    }
}

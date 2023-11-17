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
            background
            VStack(spacing: 64) {
                timerIndicator
                controlButtons
            } // END OF VSTACK
        } // END OF ZSTACK
        .navigationTitle("ClockIn")
        .toolbar { toolbar }
    } // END OF BODY
    
    var background: some View {
        BackgroundFactory.buildSolidColor()
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
            .tint(.primary)
            .accessibilityIdentifier(Identifier.settingNavigationButton.rawValue)
        } // END OF TOOLBAR ITEM
    }
} // END OF VIEW

//MARK: - TIMER CONTROLS
extension HomeView {
    var controlButtons: some View {
        HStack(spacing: 50) {
            if viewModel.isStarted {
                finishButton
            } // END OF IF
            startPauseButton
        }
    }
    
    var finishButton: some View {
        Button {
            viewModel.stopTimer()
        } label: {
            Image(systemName: "stop.fill")
                .resizable()
                .foregroundColor(.primary)
                .frame(width: 50, height: 50)
        }
        .accessibilityIdentifier(Identifier.finishButton.rawValue)
    }
    
    var startPauseButton: some View {
        Button {
            viewModel.isStarted ? viewModel.isRunning.toggle() : viewModel.startTimer()
        } label: {
            Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                .resizable()
        } // END OF BUTTON
        .accessibilityIdentifier(Identifier.startPauseButton.rawValue)
        .accentColor(.primary)
        .frame(width: 50, height: 50)
    }
}

// MARK: - TIMER INDICATORS
extension HomeView {
    var timerIndicator: some View {
        ZStack {
            timerLabel
            worktimeProgressRing
            if viewModel.overtimeProgress > 0 {
                overtimeProgressRing
            }
        }
    }
    
    var timerLabel: some View {
        Text("\(viewModel.timerStringValue)")
            .accessibilityIdentifier(Identifier.timerLabel.rawValue)
            .foregroundColor(.primary)
            .font(.largeTitle)
    }
    
    var worktimeProgressRing: some View {
        return RingView(startPoint: $viewModel.progress,
                        endPoint: .constant(1),
                        ringColor: .primary,
                        ringWidth: 5,
                        displayPointer: false)
            .frame(width: UIScreen.main.bounds.size.width-120,
                   height: UIScreen.main.bounds.size.width-120)
    }
    
    var overtimeProgressRing: some View {
            RingView(startPoint: .constant(0),
                     endPoint: $viewModel.overtimeProgress,
                     ringColor: .secondary,
                     ringWidth: 5,
                     displayPointer: false)
                .frame(width: UIScreen.main.bounds.size.width-120, height: UIScreen.main.bounds.size.width-120)
    }
    
}

//MARK: - PREVIEW
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

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
    let timerIndicatorFormatter = FormatterFactory.makeDateComponentFormatter()
    let titleText: String = "ClockIn"
    let settingText: String = "Settings"
    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            background
            VStack(spacing: 64) {
                timerIndicator
                makeControls(viewModel.state)
            } // END OF VSTACK
        } // END OF ZSTACK
        .navigationTitle(titleText)
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
                                    settingsStore: container.settingsStore
                                ))
            } label: {
                Label(settingText, systemImage: "gearshape.fill")
            } // END OF NAV LINK
            .tint(.primary)
            .accessibilityIdentifier(Identifier.settingNavigationButton.rawValue)
        } // END OF TOOLBAR ITEM
    }
} // END OF VIEW

//MARK: - TIMER CONTROLS
extension HomeView {
    @ViewBuilder
    func makeControls(_ state: TimerService.TimerServiceState) -> some View {
        switch state {
        case .running:
            HStack(spacing: 50) {
                pauseButton
                finishButton
            }
        case .paused:
            HStack(spacing: 50) {
                resumeButton
                finishButton
            }
        case .notStarted, .finished:
            startButton
        }
    }
    
    var finishButton: some View {
        Button {
            viewModel.stopTimerService()
        } label: {
            Image(systemName: "stop.fill")
                .resizable()
                .foregroundColor(.primary)
                .frame(width: 50, height: 50)
        }
        .accessibilityIdentifier(Identifier.finishButton.rawValue)
    }
    
    var startButton: some View {
        Button {
            viewModel.startTimerService()
        } label: {
            Image(systemName: viewModel.state  == .running ? "pause.fill" : "play.fill")
                .resizable()
        } // END OF BUTTON
        .accessibilityIdentifier(Identifier.startButton.rawValue)
        .accentColor(.primary)
        .frame(width: 50, height: 50)
    }
    
    var resumeButton: some View {
        Button {
            viewModel.resumeTimerService()
        } label: {
            Image(systemName: "play.fill")
                .resizable()
        } // END OF BUTTON
        .accessibilityIdentifier(Identifier.resumeButton.rawValue)
        .accentColor(.primary)
        .frame(width: 50, height: 50)
    }
    
    var pauseButton: some View {
        Button {
            viewModel.pauseTimerService()
        } label: {
            Image(systemName: "pause.fill")
                .resizable()
        } // END OF BUTTON
        .accessibilityIdentifier(Identifier.pauseButton.rawValue)
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
        Text(formatTimeInterval(viewModel.timerDisplayValue))
            .accessibilityIdentifier(Identifier.timerLabel.rawValue)
            .foregroundColor(.primary)
            .font(.largeTitle)
    }
    
    var worktimeProgressRing: some View {
        return RingView(startPoint: 0,
                        endPoint: viewModel.normalProgress,
                        ringColor: .primary,
                        ringWidth: 5,
                        displayPointer: false
        )
            .frame(width: UIScreen.main.bounds.size.width-120,
                   height: UIScreen.main.bounds.size.width-120)
    }
    
    var overtimeProgressRing: some View {
            RingView(startPoint: 0,
                     endPoint: viewModel.overtimeProgress,
                     ringColor: .red,
                     ringWidth: 5,
                     displayPointer: false
            )
                .frame(width: UIScreen.main.bounds.size.width-120,
                       height: UIScreen.main.bounds.size.width-120)
    }
    func formatTimeInterval(_ value: TimeInterval) -> String {
        return timerIndicatorFormatter.string(from: value) ?? "\(value)"
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
                                                  payManager: container.payManager,
                                                  timerProvider: container.timerProvider))
            }
            .environmentObject(Container())
        }
    }
    static var previews: some View {
        ContainerView()
    }
}

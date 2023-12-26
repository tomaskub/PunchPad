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
        BackgroundFactory.buildSolidWithStrip(
            solid: .theme.background,
            strip: .theme.white
        )
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
                Label(settingText, systemImage: "gearshape")
            } // END OF NAV LINK
            .tint(.theme.primary)
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
            HStack {
                pauseButton
                finishButton
            }
        case .paused:
            HStack {
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
                .frame(width: 30, height: 30)
                .frame(width: 60, height: 60)
        }
        .buttonStyle(CircleButton())
        .accessibilityIdentifier(Identifier.finishButton.rawValue)
    }
    
    var startButton: some View {
        Button {
            viewModel.startTimerService()
        } label: {
            Image(systemName: "play.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .offset(x: 5)
                .frame(width: 100, height: 100)
        } // END OF BUTTON
        .buttonStyle(CircleButton())
        .accessibilityIdentifier(Identifier.startButton.rawValue)
        
    }
    
    var resumeButton: some View {
        Button {
            viewModel.resumeTimerService()
        } label: {
            Image(systemName: "play.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .frame(width: 100, height: 100)
        } // END OF BUTTON
        .buttonStyle(CircleButton())
        .accessibilityIdentifier(Identifier.resumeButton.rawValue)
    }
    
    var pauseButton: some View {
        Button {
            viewModel.pauseTimerService()
        } label: {
            Image(systemName: "pause.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .frame(width: 100, height: 100)
        } // END OF BUTTON
        .buttonStyle(CircleButton())
        .accessibilityIdentifier(Identifier.pauseButton.rawValue)
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
            TabView {
                NavigationView {
                    HomeView(viewModel: HomeViewModel(dataManager: container.dataManager,
                                                      settingsStore: container.settingsStore,
                                                      payManager: container.payManager,
                                                      timerProvider: container.timerProvider))
                }
                .tabItem { Label(
                    title: { Text("Home") },
                    icon: { Image(systemName: "house.fill") }
                ) }
                .environmentObject(Container())
            }
        }
    }
    static var previews: some View {
        ContainerView()
    }
}

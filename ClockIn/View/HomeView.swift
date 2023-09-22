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
                GradientFactory.build(colorScheme: colorScheme)
                // CONTENT
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
                if viewModel.isStarted {
                    Button {
                        viewModel.isRunning.toggle()
                    } label: {
                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .resizable()
                    } // END OF BUTTON
                    .accessibilityIdentifier(Identifier.resumePauseButton.rawValue)
                    .accentColor(.primary)
                    .frame(width: 50, height: 50)
                    .offset(y: 250)
                } // END OF IF
                RingView(progress: $viewModel.progress, ringColor: .primary, pointColor: colorScheme == .light ? .white : .black)
                    .frame(width: UIScreen.main.bounds.size.width-120, height: UIScreen.main.bounds.size.width-120)
                if viewModel.overtimeProgress > 0 {
                    RingView(progress: $viewModel.overtimeProgress, ringColor: .green, pointColor: .white, ringWidth: 5, startigPoint: 0.023)
                        .frame(width: UIScreen.main.bounds.size.width-120, height: UIScreen.main.bounds.size.width-120)
                } // END OF IF
            } // END OF ZSTACK
            .navigationTitle("ClockIn")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        StatisticsView(viewModel:
                                        StatisticsViewModel(
                                            dataManager: container.dataManager,
                                            payManager: container.payManager,
                                            settingsStore: container.settingsStore))
                    } label: {
                        Text("Statistics")
                    } // END OF NAV LINK
                    .accessibilityIdentifier(Identifier.statisticsNavigationButton.rawValue)
                } // END OF TOOLBAR ITEM
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView(viewModel:
                                        SettingsViewModel(
                                            dataManger: container.dataManager,
                                            settingsStore: container.settingsStore))
                    } label: {
                        Text("Settings")
                    } // END OF NAV LINK
                    .accessibilityIdentifier(Identifier.settingNavigationButton.rawValue)
                } // END OF TOOLBAR ITEM
            } // END OF TOOLBAR
    } // END OF BODY
} // END OF VIEW

struct Home_Previews: PreviewProvider {
    private struct ContainerView: View {
        @StateObject private var container: Container = .init()
        var body: some View {
            NavigationView {
                HomeView(viewModel: HomeViewModel(dataManager: container.dataManager,settingsStore: container.settingsStore, timerProvider: container.timerProvider))
            }
            .environmentObject(Container())
        }
    }
    static var previews: some View {
        ContainerView()
    }
}

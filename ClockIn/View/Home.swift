//
//  Home.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI

struct Home: View {
    private typealias Identifier = ScreenIdentifier.HomeView
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var timer: TimerModel
    
    var body: some View {
            ZStack {
                //BACKGROUND LAYER
                GradientFactory.build(colorScheme: colorScheme)
                // CONTENT
                Button(action:
                        timer.isStarted ? timer.stopTimer : timer.startTimer) {
                    ZStack(alignment: .center) {
                        Circle()
                            .fill(.blue.opacity(0.5))
                            .padding()
                        Text("\(timer.timerStringValue)")
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
                if timer.isStarted {
                    Button {
                        timer.isRunning.toggle()
                    } label: {
                        Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                            .resizable()
                    } // END OF BUTTON
                    .accessibilityIdentifier(Identifier.resumePauseButton.rawValue)
                    .accentColor(.primary)
                    .frame(width: 50, height: 50)
                    .offset(y: 250)
                } // END OF IF
                RingView(progress: $timer.progress, ringColor: .primary, pointColor: colorScheme == .light ? .white : .black)
                    .frame(width: UIScreen.main.bounds.size.width-120, height: UIScreen.main.bounds.size.width-120)
                if timer.overtimeProgress > 0 {
                    RingView(progress: $timer.overtimeProgress, ringColor: .green, pointColor: .white, ringWidth: 5, startigPoint: 0.023)
                        .frame(width: UIScreen.main.bounds.size.width-120, height: UIScreen.main.bounds.size.width-120)
                } // END OF IF
            } // END OF ZSTACK
            .navigationTitle("ClockIn")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        StatisticsView(viewModel: StatisticsViewModel(
                            dataManager: .shared,
                            payManager: PayManager(),
                            overrideUserDefaults: false))
                    } label: {
                        Text("Statistics")
                    } // END OF NAV LINK
                    .accessibilityIdentifier(Identifier.statisticsNavigationButton.rawValue)
                } // END OF TOOLBAR ITEM
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView(viewModel: SettingsViewModel(dataManger: DataManager.shared))
                    } label: {
                        Text("Settings")
                    } // END OF NAV LINK
                    .accessibilityIdentifier(Identifier.settingNavigationButton.rawValue)
                } // END OF TOOLBAR ITEM
            } // END OF TOOLBAR
    } // END OF BODY
} // END OF VIEW

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Home()
        }
        .environmentObject(TimerModel())
    }
}

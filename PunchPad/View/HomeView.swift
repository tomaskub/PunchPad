//
//  Home.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI
import NavigationKit
import ThemeKit
import TabViewKit



struct HomeView: View {
    private typealias Identifier = ScreenIdentifier.HomeView
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject private var container: Container
    let timerIndicatorHourAndMinuteFormatter = FormatterFactory.makeHourAndMinuteDateComponentFormatter()
    let timerIndicatorMinuteAndSecondFormatter = FormatterFactory.makeMinuteAndSecondDateComponetFormatter()
    let settingText: String = "Settings"
    let bottomMessageText: String = "Start your work day!".capitalized
    
    var body: some View {
        ZStack {
            background
            VStack{
                VStack(spacing: 60) {
                    TimerIndicator(
                        timerLabel: formatTimeInterval(viewModel.timerDisplayValue),
                        firstProgress: viewModel.normalProgress,
                        secondProgress: viewModel.overtimeProgress
                    )
                    .frame(width: 260, height: 260)
                    makeControls(viewModel.state)
                } // END OF VSTACK
                .frame(height: 480, alignment: .top)
                
                Text(bottomMessageText)
                    .foregroundColor(.theme.white)
                    .opacity(viewModel.state == .notStarted ? 1 : 0)
                    .font(.system(size: 24))
                    .frame(height: 50)
                    .padding(.bottom, 34)
            }
        } // END OF ZSTACK
    } // END OF BODY
    
    var background: some View {
        BackgroundFactory.buildSolidColor()
    }
    
    func formatTimeInterval(_ value: TimeInterval) -> String {
        if value >= 3600 {
            return timerIndicatorHourAndMinuteFormatter.string(from: value) ?? "\(value)"
        } else {
            return timerIndicatorMinuteAndSecondFormatter.string(from: value) ?? "\(value)"
        }
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
            makeSmallButtonLabel(systemName: "stop.fill")
        }
        .buttonStyle(CircleButton())
        .accessibilityIdentifier(Identifier.finishButton.rawValue)
    }
    
    var startButton: some View {
        Button {
            viewModel.startTimerService()
        } label: {
            makeLargeButtonLabel(systemName: "play.fill",
                                 offset: CGSize(width: 6, height: 0)
            )
        } // END OF BUTTON
        .buttonStyle(CircleButton())
        .accessibilityIdentifier(Identifier.startButton.rawValue)
        
    }
    
    var resumeButton: some View {
        Button {
            viewModel.resumeTimerService()
        } label: {
            makeLargeButtonLabel(systemName: "play.fill")
        } // END OF BUTTON
        .buttonStyle(CircleButton())
        .accessibilityIdentifier(Identifier.resumeButton.rawValue)
    }
    
    var pauseButton: some View {
        Button {
            viewModel.pauseTimerService()
        } label: {
            makeLargeButtonLabel(systemName: "pause.fill")
        } // END OF BUTTON
        .buttonStyle(CircleButton())
        .accessibilityIdentifier(Identifier.pauseButton.rawValue)
    }
    
    @ViewBuilder
    func makeSmallButtonLabel(systemName: String, offset: CGSize? = nil) -> some View {
        Image(systemName: systemName)
            .resizable()
            .frame(width: 40, height: 40)
            .ifLet(offset, transform: { image, offset in
                image.offset(offset)
            })
            .frame(width: 98, height: 98)
    }
    
    @ViewBuilder
    func makeLargeButtonLabel(systemName: String, offset: CGSize? = nil) -> some View {
        Image(systemName: systemName)
            .resizable()
            .frame(width: 60, height: 60)
            .ifLet(offset, transform: { image, offset in
                image.offset(offset)
            })
            .frame(width: 160, height: 160)
    }
}

//MARK: - PREVIEW
struct Home_Previews: PreviewProvider {
    private struct ContainerView: View {
        @StateObject private var container: Container = .init()
        
        var body: some View {
            HomeView(viewModel:
                        HomeViewModel(
                            dataManager: container.dataManager,
                            settingsStore: container.settingsStore,
                            payManager: container.payManager, 
                            notificationService: container.notificationService,
                            timerProvider: container.timerProvider
                        )
            )
            .environmentObject(Container())
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}

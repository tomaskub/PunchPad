//
//  Home.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import DomainModels
import FoundationExtensions
import UIComponents
import SwiftUI
import NavigationKit
import ThemeKit
import TabViewKit

struct HomeView: View {
    private typealias Identifier = ScreenIdentifier.HomeView
    private let timerIndicatorHourAndMinuteFormatter = FormatterFactory.makeHourAndMinuteDateComponentFormatter()
    private let timerIndicatorMinuteAndSecondFormatter = FormatterFactory.makeMinuteAndSecondDateComponetFormatter()
    private let stopIconName = "stop.fill"
    private let playIconName = "play.fill"
    private let pauseIconName = "pause.fill"
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            background
            VStack {
                VStack(spacing: 60) {
                    TimerIndicator(
                        timerLabel: formatTimeInterval(viewModel.timerDisplayValue),
                        firstProgress: viewModel.normalProgress,
                        firstTimerLabel: Strings.firstTimerLabelText,
                        secondProgress: viewModel.overtimeProgress,
                        secondTimerLabel: Strings.secondTimerLabelText
                    )
                    .frame(width: 260, height: 260)
                    // todo: investigate error and why it now appeared 
                    makeControls(viewModel.state)
                }
                .frame(height: 480, alignment: .top)
                
                Text(Strings.bottomMessageText)
                    .foregroundColor(.theme.white)
                    .opacity(viewModel.state == .notStarted ? 1 : 0)
                    .font(.system(size: 24))
                    .frame(height: 50)
                    .padding(.bottom, 34)
            }
        }
    }
    
    private var background: some View {
        BackgroundFactory.buildSolidColor()
    }
    
    private func formatTimeInterval(_ value: TimeInterval) -> String {
        if value >= 3600 {
            return timerIndicatorHourAndMinuteFormatter.string(from: value) ?? "\(value)"
        } else {
            return timerIndicatorMinuteAndSecondFormatter.string(from: value) ?? "\(value)"
        }
    }
}

// MARK: - Localization
extension HomeView: Localized {
    struct Strings {
        static let bottomMessageText = Localization.HomeScreen.startYourWorkDay.capitalized
        static let firstTimerLabelText = Localization.Common.worktime.uppercased()
        static let secondTimerLabelText = Localization.Common.overtime.uppercased()
    }
}

// MARK: - Timer Controls
private extension HomeView {
    @ViewBuilder
    func makeControls(_ state: TimerServiceState) -> some View {
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
            makeSmallButtonLabel(systemName: stopIconName)
        }
        .buttonStyle(CircleButton())
        .accessibilityIdentifier(Identifier.finishButton.rawValue)
    }
    
    var startButton: some View {
        Button {
            viewModel.startTimerService()
        } label: {
            makeLargeButtonLabel(systemName: playIconName,
                                 offset: CGSize(width: 6, height: 0)
            )
        }
        .buttonStyle(CircleButton())
        .accessibilityIdentifier(Identifier.startButton.rawValue)
    }
    
    var resumeButton: some View {
        Button {
            viewModel.resumeTimerService()
        } label: {
            makeLargeButtonLabel(systemName: playIconName)
        }
        .buttonStyle(CircleButton())
        .accessibilityIdentifier(Identifier.resumeButton.rawValue)
    }
    
    var pauseButton: some View {
        Button {
            viewModel.pauseTimerService()
        } label: {
            makeLargeButtonLabel(systemName: pauseIconName)
        }
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

// MARK: - Preview
struct Home_Previews: PreviewProvider {
    private struct ContainerView: View {
        private let container = PreviewContainer()
        
        var body: some View {
            HomeView(viewModel:
                        HomeViewModel(
                            dataManager: container.dataManager,
                            settingsStore: container.settingsStore,
                            payManager: container.payManager,
                            notificationService: container.notificationService,
                            timerProvider: container.timerProvider)
            )
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}

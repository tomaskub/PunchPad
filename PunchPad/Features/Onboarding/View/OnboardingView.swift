//
//  OnboardingView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/22/23.
//

import SwiftUI
import ThemeKit

struct OnboardingView: View {
    private typealias Identifier = ScreenIdentifier.OnboardingView
    private enum OnboardingStage: Equatable, CaseIterable {
        case welcome, worktime, overtime, notifications, salary, exit
    }
    
    private var bottomButtonText: String {
        switch currentStage {
        case .welcome: Strings.bottomButtonWelcomeText
        case .exit: Strings.bottomButtonExitText
        default: Strings.bottomButtonDefaultText
        }
    }
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: OnboardingViewModel
    @State private var currentStage: OnboardingStage = .welcome
    
    init(viewModel: OnboardingViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        ZStack{
            background
                switch currentStage {
                case .welcome:
                    OnboardingWelcomeView()
                case .worktime:
                    OnboardingWorktimeView(viewModel: viewModel)
                case .overtime:
                    OnboardingOvertimeView(viewModel: viewModel)
                case .notifications:
                    OnboardingNotificationView(viewModel: viewModel)
                case .salary:
                    OnboardingSalaryView(viewModel: viewModel)
                case .exit:
                    OnboardingFinishView()
                }
            
            VStack {
                if currentStage != .welcome {
                    HStack {
                        topButton
                        Spacer()
                    }
                }
                Spacer()
                bottomNavigationButton
            }
            .padding(30)
        }
    }
}

extension OnboardingView {
    private var background: some View {
        BackgroundFactory.buildSolidColor()
    }
    
    private var topButton: some View {
        Label(Strings.backButtonText, systemImage: "chevron.left")
            .accessibilityIdentifier(Identifier.Buttons.regressStage)
            .foregroundColor(.theme.blackLabel)
            .onTapGesture {
                withAnimation(.spring()) {
                    currentStage = currentStage.previous()
                }
            }
    }
    
    private var bottomNavigationButton: some View {
        Button(bottomButtonText) {
            withAnimation(.easeInOut) {
                if currentStage == .exit {
                    dismiss()
                } else {
                    currentStage = currentStage.next()
                }
            }
        }
        .buttonStyle(.confirming)
        .accessibilityIdentifier(Identifier.Buttons.advanceStage)
    }
}

//MARK: - Localization
extension OnboardingView: Localized {
    struct Strings {
        static let backButtonText = Localization.Common.back.capitalized
        static let bottomButtonWelcomeText = Localization.OnboardingScreen.letsStart
        static let bottomButtonExitText = Localization.OnboardingScreen.finishSetUp
        static let bottomButtonDefaultText = Localization.Common.next.capitalized
    }
}

#Preview {
    struct ContainerView: View {
        private let container = PreviewContainer()
        var body: some View {
            OnboardingView(viewModel:
                            OnboardingViewModel(notificationService: container.notificationService,
                                                settingsStore: container.settingsStore))
        }
    }
    return ContainerView()
}

//
//  OnboardingView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/22/23.
//

import SwiftUI
import ThemeKit

struct OnboardingView: View {
    private enum OnboardingStage: Equatable, CaseIterable {
        case welcome // Logo and welcome message
        case worktime // Set the work time
        case overtime // Ask if doing overtime and set maximum overtime
        case notifications // Ask if send notifications on finish
        case salary // Ask user for salary and if to calculate net salary (after taxes)
        case exit // Inform setup complete, allow to finish onboarding
    }
    private typealias Identifier = ScreenIdentifier.OnboardingView
    
    let backButtonText: String = "Back"
    private var bottomButtonText: String {
        switch currentStage {
        case .welcome: "Let's start!"
        case .exit: "Finish set up!"
        default: "Next"
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: OnboardingViewModel
    @State private var currentStage: OnboardingStage = .welcome
    
    init(viewModel: OnboardingViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        ZStack{
            background
            //CONTENT
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
        Label(backButtonText, systemImage: "chevron.left")
            .accessibilityIdentifier(Identifier.Buttons.regressStage.rawValue)
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
        .accessibilityIdentifier(Identifier.Buttons.advanceStage.rawValue)
    }
}

#Preview {
    struct ContainerView: View {
        @StateObject private var container: Container = Container()
        var body: some View {
            OnboardingView(viewModel:
                            OnboardingViewModel(notificationService: container.notificationService,
                                                settingsStore: container.settingsStore))
        }
    }
    return ContainerView()
}

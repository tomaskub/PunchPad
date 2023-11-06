//
//  OnboardingView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/22/23.
//

import SwiftUI

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
    private let tansition: AnyTransition = .asymmetric(
        insertion: .move(edge: .trailing),
        removal: .move(edge: .leading)
    )
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: OnboardingViewModel
    @State private var currentStage: OnboardingStage = .welcome
    
    init(viewModel: OnboardingViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        ZStack{
            //BACKGROUND
            GradientFactory.build(colorScheme: colorScheme)
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
                    stage5Screen
                }
            
            VStack {
                if currentStage != .welcome {
                    HStack {
                        topButton
                        Spacer()
                    }
                }
                Spacer()
                bottomButton
            }
            .padding(30)
        }
    }
}

extension OnboardingView {
    private var bottomButtonText: String {
        currentStage == .welcome ? "Let's start!" :
                                currentStage == .exit ? "Finish set up!" : "Next"
    }
    
    private var stage5Screen: some View {
        VStack(spacing: 40) {
            
            Text("Clock In has been succsessfully set up")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("You are all ready to go! Enjoy using the app!")
                .multilineTextAlignment(.center)
            
            //This section is still in works until in-app tutorial is developed
            /*
             Text("To enter a short tutorial on how to use the app and its functions click the tour button. Alternatively, if you are a person that assembles the IKEA furniture without looking at the instructions click the finish button")
             .multilineTextAlignment(.center)
             
             
             Text("Finish!")
             .font(.headline)
             .foregroundColor(.accentColor)
             .frame(height: 55)
             .frame(maxWidth: .infinity)
             .background(Color.primary.colorInvert())
             .cornerRadius(10)
             .overlay {
             HStack {
             Spacer()
             Image(systemName: "bicycle")
             Image(systemName: "figure.walk")
             }
             .padding()
             }
             .onTapGesture {
             dismiss()
             }
             */
        }
        .padding(30)
    }
    
    private var topButton: some View {
        Text("Back")
            .accessibilityIdentifier(Identifier.Buttons.regressStage.rawValue)
            .foregroundColor(.accentColor)
            .onTapGesture {
                withAnimation(.spring()) {
                    currentStage = currentStage.previous()
                }
            }
    }
    
    private var bottomButton: some View {
        ButtonFactory.build(labelText: bottomButtonText)
        .onTapGesture {
            withAnimation(.spring()) {
                if currentStage == .exit {
                    dismiss()
                } else {
                    currentStage = currentStage.next()
                }
            }
        }
        //This section is still in works until in-app tutorial is developed
        /*
         .overlay(content: {
         if onboardingStage == 4 {
         HStack {
         Spacer()
         Image(systemName: "figure.outdoor.cycle")
         }
         .padding(.trailing)
         }
         })
         */
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(viewModel: OnboardingViewModel(settingsStore: SettingsStore()))
    }
}

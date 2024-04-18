//
//  OnboardingWorktimeView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 05/11/2023.
//

import SwiftUI

struct OnboardingWorktimeView: View {
    private let titleText: String = "Workday"
    private let descriptionText: String = "PunchPad needs to know your normal workday length to let you know when you are done or when you enter into overtime"
    private let hoursPickerLabel: String = "Hours"
    private let minutesPickerLabel: String = "Minutes"
    
    private typealias Identifier = ScreenIdentifier.OnboardingView
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            title
            description
            HStack {
                VStack {
                    Text(hoursPickerLabel)
                        .foregroundColor(.theme.primary)
                    Picker(hoursPickerLabel,
                           selection: $viewModel.hoursWorking) {
                        ForEach(0..<25){ i in
                            Text("\(i)")
                                .foregroundColor(.theme.primary)
                                .tag(i)
                        }
                    }
                    .accessibilityIdentifier(Identifier.Pickers.workingHours.rawValue)
                    .pickerStyle(.wheel)
                }
                VStack {
                    Text(minutesPickerLabel)
                        .foregroundColor(.theme.primary)
                    Picker(minutesPickerLabel,
                           selection: $viewModel.minutesWorking) {
                        ForEach(0..<60) { i in
                            Text("\(i)")
                                .foregroundColor(.theme.primary)
                                .tag(i)
                        }
                    }
                    .accessibilityIdentifier(Identifier.Pickers.workingMinutes.rawValue)
                    .pickerStyle(.wheel)
                }
            }
            .padding()
            .padding(.top)
            .background(Color.theme.white)
            .cornerRadius(20)
        }
        .padding(30)
    }
    
    private var title: some View {
        TextFactory.buildTitle(titleText)
    }
    
    private var description: some View {
        TextFactory.buildDescription(descriptionText)
    }
}

struct OnbardingWorktime_Previews: PreviewProvider {
    
    private struct PreviewContainerView: View {
        @Environment(\.colorScheme) private var colorScheme
        @StateObject private var vm: OnboardingViewModel
        private let container: PreviewContainer
        
        init() {
            let container = PreviewContainer()
            self.container = container
            self._vm = StateObject(wrappedValue: 
                                    OnboardingViewModel(notificationService: container.notificationService,
                                                        settingsStore: container.settingsStore)
            )
        }
        
        var body: some View {
            ZStack {
                BackgroundFactory.buildSolidColor()
                OnboardingWorktimeView(viewModel: vm)
                VStack {
                    Spacer()
                    Button("Preview button") {
                        
                    }
                    .buttonStyle(.confirming)
                }
                .padding(30)
            }
        }
    }
    
    static var previews: some View {
        PreviewContainerView()
    }
}

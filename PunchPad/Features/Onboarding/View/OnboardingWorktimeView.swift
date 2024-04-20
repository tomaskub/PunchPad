//
//  OnboardingWorktimeView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 05/11/2023.
//

import SwiftUI

struct OnboardingWorktimeView: View {
    private typealias Identifier = ScreenIdentifier.OnboardingView
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            title
            description
            HStack {
                VStack {
                    Text(Strings.hoursPickerLabel)
                        .foregroundColor(.theme.primary)
                    Picker(Strings.hoursPickerLabel,
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
                    Text(Strings.minutesPickerLabel)
                        .foregroundColor(.theme.primary)
                    Picker(Strings.minutesPickerLabel,
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
        TextFactory.buildTitle(Strings.titleText)
    }
    
    private var description: some View {
        TextFactory.buildDescription(Strings.descriptionText)
    }
}

//MARK: - Localization
extension OnboardingWorktimeView: Localized {
    struct Strings {
        static let titleText = Localization.OnbardingWorktime.workday
        static let descriptionText = Localization.OnbardingWorktime.description
        static let hoursPickerLabel = Localization.OnbardingWorktime.hours
        static let minutesPickerLabel = Localization.OnbardingWorktime.minutes
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

//
//  OnboardingOvertimeView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 05/11/2023.
//

import SwiftUI
import ThemeKit

struct OnboardingOvertimeView: View {
    private typealias Identifier = ScreenIdentifier.OnboardingView
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            title
            
            if !viewModel.settingsStore.isLoggingOvertime {
                toggleDescription
            }
            
            overtimeToggle
            
            if viewModel.settingsStore.isLoggingOvertime {
                pickerDescription
                HStack {
                    VStack {
                        Text(Strings.hoursPickerLabel)
                            .foregroundColor(.theme.primary)
                        Picker(Strings.hoursPickerLabel,
                               selection: $viewModel.hoursOvertime) {
                            ForEach(0..<25) { hours in
                                Text("\(hours)")
                                    .foregroundColor(.theme.primary).tag(hours)
                            }
                        }
                               .accessibilityIdentifier(Identifier.Pickers.overtimeHours.rawValue)
                               .pickerStyle(.wheel)
                    }
                    VStack {
                        Text(Strings.minutesPickerLabel)
                            .foregroundColor(.theme.primary)
                        Picker(Strings.minutesPickerLabel,
                               selection: $viewModel.minutesOvertime) {
                            ForEach(0..<60) { minutes in
                                Text("\(minutes)").foregroundColor(.theme.primary).tag(minutes)
                            }
                        }
                               .accessibilityIdentifier(Identifier.Pickers.overtimeMinutes.rawValue)
                               .pickerStyle(.wheel)
                    }
                }
                .foregroundColor(.theme.primary)
                .padding()
                .padding(.top)
                .background(Color.primary.colorInvert())
                .cornerRadius(20)
            }
            
        }
        .padding(30)
    }
    
    var title: some View {
        TextFactory.buildTitle(Strings.titleText)
    }
    private var toggleDescription: some View {
        TextFactory.buildDescription(Strings.toggleDescriptionText)
    }
    private var pickerDescription: some View {
        TextFactory.buildDescription(Strings.pickerDescriptionText)
    }
    
    private var overtimeToggle: some View {
        Toggle(Strings.toggleLabel,
               isOn: $viewModel.settingsStore.isLoggingOvertime.animation(.easeInOut))
        .foregroundColor(.theme.blackLabel)
        .tint(.theme.primary)
            .accessibilityIdentifier(Identifier.Toggles.overtime.rawValue)
            .padding()
            .background()
            .cornerRadius(16)
    }
}

// MARK: - Localization
extension OnboardingOvertimeView: Localized {
    struct Strings {
        static let titleText = Localization.Common.overtime.capitalized
        static let toggleDescriptionText = Localization.OnboardingOvertimeScreen.letMeasureOvertime
        static let pickerDescriptionText = Localization.OnboardingOvertimeScreen.letKnowMaximumOvertime
        static let hoursPickerLabel = Localization.Common.hours.capitalized
        static let minutesPickerLabel = Localization.Common.minutes.capitalized
        static let toggleLabel = Localization.OnboardingOvertimeScreen.keepLoggingOvertime
    }
}

struct OnbardingOvertimePreviews: PreviewProvider {
    
    private struct PreviewContainerView: View {
        @Environment(\.colorScheme) private var colorScheme
        @StateObject private var viewModel: OnboardingViewModel
        private let container: PreviewContainer
        
        init() {
            let container = PreviewContainer()
            self.container = container
            self._viewModel = StateObject(wrappedValue: OnboardingViewModel(notificationService: container.notificationService, 
                                                                     settingsStore: container.settingsStore))
        }
        
        var body: some View {
            ZStack {
                BackgroundFactory.buildSolidColor()
                OnboardingOvertimeView(viewModel: viewModel)
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

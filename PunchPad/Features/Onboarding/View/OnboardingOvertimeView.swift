//
//  OnboardingOvertimeView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 05/11/2023.
//

import SwiftUI
import ThemeKit

struct OnboardingOvertimeView: View {
    let titleText: String = "Overtime"
    let toggleDescriptionText: String = "Let PunchPad know wheter you want to measure overtime"
    let pickerDescriptionText: String = "Let the app know maximum overtime you can work for."
    let hoursPickerLabel: String = "Hours"
    let minutesPickerLabel: String = "Minutes"
    let toggleLabel: String = "Keep logging overtime"
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
                        Text(hoursPickerLabel)
                            .foregroundColor(.theme.primary)
                        Picker(hoursPickerLabel,
                               selection: $viewModel.hoursOvertime) {
                            ForEach(0..<25){ i in
                                Text("\(i)")
                                    .foregroundColor(.theme.primary).tag(i)
                            }
                        }
                               .accessibilityIdentifier(Identifier.Pickers.overtimeHours.rawValue)
                               .pickerStyle(.wheel)
                    }
                    VStack {
                        Text(minutesPickerLabel)
                            .foregroundColor(.theme.primary)
                        Picker(minutesPickerLabel,
                               selection: $viewModel.minutesOvertime) {
                            ForEach(0..<60) { i in
                                Text("\(i)").foregroundColor(.theme.primary).tag(i)
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
        TextFactory.buildTitle(titleText)
    }
    private var toggleDescription: some View {
        TextFactory.buildDescription(toggleDescriptionText)
    }
    private var pickerDescription: some View {
        TextFactory.buildDescription(pickerDescriptionText)
    }
    
    private var overtimeToggle: some View {
        Toggle(toggleLabel,
               isOn: $viewModel.settingsStore.isLoggingOvertime.animation(.easeInOut))
        .foregroundColor(.theme.blackLabel)
        .tint(.theme.primary)
            .accessibilityIdentifier(Identifier.Toggles.overtime.rawValue)
            .padding()
            .background()
            .cornerRadius(16)
    }
    
    
}

struct OnbardingOvertime_Previews: PreviewProvider {
    
    private struct PreviewContainerView: View {
        @Environment(\.colorScheme) private var colorScheme
        @StateObject private var vm: OnboardingViewModel
        private let container: PreviewContainer
        
        init() {
            let container = PreviewContainer()
            self.container = container
            self._vm = StateObject(wrappedValue: OnboardingViewModel(notificationService: container.notificationService, 
                                                                     settingsStore: container.settingsStore))
        }
        
        var body: some View {
            ZStack {
                BackgroundFactory.buildSolidColor()
                OnboardingOvertimeView(viewModel: vm)
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

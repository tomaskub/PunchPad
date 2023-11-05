//
//  OnboardingOvertimeView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 05/11/2023.
//

import SwiftUI

struct OnboardingOvertimeView: View {
    let titleText: String = "Overtime"
    let toggleDescriptionText: String = "Let ClockIn know wheter you want to measure overtime"
    let pickerDescriptionText: String = "Let the app know what is the maximum overtime you can work for."
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
                        Picker(hoursPickerLabel, 
                               selection: $viewModel.hoursOvertime) {
                            ForEach(0..<25){ i in
                                Text("\(i)").tag(i)
                            }
                        }
                        .accessibilityIdentifier(Identifier.Pickers.overtimeHours.rawValue)
                        .pickerStyle(.wheel)
                    }
                    VStack {
                        Text(minutesPickerLabel)
                        Picker(minutesPickerLabel,
                               selection: $viewModel.minutesOvertime) {
                            ForEach(0..<60) { i in
                                Text("\(i)").tag(i)
                            }
                        }
                        .accessibilityIdentifier(Identifier.Pickers.overtimeMinutes.rawValue)
                        .pickerStyle(.wheel)
                    }
                }
                .padding()
                .padding(.top)
                .background(Color.primary.colorInvert())
                .cornerRadius(20)
            }
        }
        .padding(30)
    } // END OF BODY
    
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
               isOn: $viewModel.settingsStore.isLoggingOvertime)
            .accessibilityIdentifier(Identifier.Toggles.overtime.rawValue)
            .padding()
            .background()
            .cornerRadius(20)
    }
    
    
} // END OF VIEW

struct OnbardingOvertime_Previews: PreviewProvider {
    
    private struct PreviewContainerView: View {
        @Environment(\.colorScheme) private var colorScheme
        @StateObject private var vm: OnboardingViewModel
        @StateObject private var container: Container
        
        init() {
            let container = Container()
            self._container = StateObject(wrappedValue: container)
            self._vm = StateObject(wrappedValue: OnboardingViewModel(settingsStore: container.settingsStore))
        }
        
        var body: some View {
            ZStack {
                GradientFactory.build(colorScheme: colorScheme)
                OnboardingOvertimeView(viewModel: vm)
                VStack {
                    Spacer()
                    ButtonFactory.build(labelText: "Preview button")
                } // END OF VSTACK
                .padding(30)
            } // END OF ZSTACK
        } // END OF BODY
    } // END OF VIEW
    
    static var previews: some View {
        PreviewContainerView()
    }
}

//
//  OnboardingWorktimeView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 05/11/2023.
//

import SwiftUI

struct OnboardingWorktimeView: View {
    
    let titleText: String = "Workday"
    let descriptionText: String = "ClockIn needs to know what is your normal workday length to let you know when you are done or when you enter into overtime"
    let hoursPickerLabel: String = "Hours"
    let minutesPickerLabel: String = "Minutes"
    
    private typealias Identifier = ScreenIdentifier.OnboardingView
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            title
            description
            HStack {
                VStack {
                    Text(hoursPickerLabel)
                    Picker(hoursPickerLabel, 
                           selection: $viewModel.hoursWorking) {
                        ForEach(0..<25){ i in
                            Text("\(i)").tag(i)
                        }
                    } // END OF PICKER
                    .accessibilityIdentifier(Identifier.Pickers.workingHours.rawValue)
                    .pickerStyle(.wheel)
                } // END OF VSTACK
                VStack {
                    Text(minutesPickerLabel)
                    Picker(minutesPickerLabel,
                           selection: $viewModel.minutesWorking) {
                        ForEach(0..<60) { i in
                            Text("\(i)").tag(i)
                        }
                    } // END OF PICKER
                    .accessibilityIdentifier(Identifier.Pickers.workingMinutes.rawValue)
                    .pickerStyle(.wheel)
                } // END OF VSTACK
            } // END OF HSTACK
            .padding()
            .padding(.top)
            .background(Color.primary.colorInvert())
            .cornerRadius(20)
        } // END OF VSTACK
        .padding(30)
    } // END OF BODY
    
    var title: some View {
        TextFactory.buildTitle(titleText)
    }
    
    var description: some View {
        TextFactory.buildDescription(descriptionText)
    }
} // END OF VIEW

struct OnbardingWorktime_Previews: PreviewProvider {
    
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
                BackgroundFactory.buildGradient(colorScheme: colorScheme)
                OnboardingWorktimeView(viewModel: vm)
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

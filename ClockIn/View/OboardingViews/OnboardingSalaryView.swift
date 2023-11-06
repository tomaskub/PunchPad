//
//  OnboardingSalaryView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 06/11/2023.
//

import SwiftUI

struct OnboardingSalaryView: View {
    let titleText: String = "Salary"
    let description1Text: String = "To let ClockIn calculate the salary you need to enter your gross montly income"
    let description2Text: String = "Do you want to allow ClockIn to calculate your net salary based on Polish tax law?"
    let paycheckText: String = "Gross paycheck"
    let currencyText: String = "PLN"
    let netSalaryToggleText: String = "Calculate net salary"
    private typealias Identifier = ScreenIdentifier.OnboardingView
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            title
            description1
            grossPaycheckTextField
            description2
            netSalaryToggle
        }
        .padding(30)
    }
    
    var title: some View {
        TextFactory.buildTitle(titleText)
    }
    var description1: some View {
        TextFactory.buildDescription(description1Text)
    }
    var description2: some View {
        TextFactory.buildDescription(description2Text)
    }
    var grossPaycheckTextField: some View {
        HStack {
            Text(paycheckText)
            TextField("", text: $viewModel.grossPayPerMonthText)
                .accessibilityIdentifier(Identifier.TextFields.grossPaycheck.rawValue)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            Text(currencyText)
        }
        .padding()
        .background()
        .cornerRadius(20)
    }
    var netSalaryToggle: some View {
        Toggle(netSalaryToggleText,
               isOn: $viewModel.settingsStore.isCalculatingNetPay)
            .accessibilityIdentifier(Identifier.Toggles.calculateNetSalary.rawValue)
            .padding()
            .background()
            .cornerRadius(20)
    }
}

struct OnboardingSalary_Preview: PreviewProvider {
    private struct PreviewContainerView: View {
        @StateObject private var vm: OnboardingViewModel
        @StateObject private var container: Container
        @Environment(\.colorScheme) private var colorScheme
        
        init() {
            let container = Container()
            self._container = StateObject(wrappedValue: container)
            self._vm = StateObject(wrappedValue: OnboardingViewModel(settingsStore: container.settingsStore))
        }
        
        var body: some View {
            ZStack {
                GradientFactory.build(colorScheme: colorScheme)
                OnboardingSalaryView(viewModel: vm)
                VStack {
                    Spacer()
                    ButtonFactory.build(labelText: "Preview button")
                        .padding(30)
                }
            }
        }
    }
    static var previews: some View {
        PreviewContainerView()
    }
}

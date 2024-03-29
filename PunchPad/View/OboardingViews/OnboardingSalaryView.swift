//
//  OnboardingSalaryView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 06/11/2023.
//

import SwiftUI
import ThemeKit

struct OnboardingSalaryView: View {
    let titleText: String = "Salary"
    let description1Text: String = "To let PunchPad calculate your salary you need to enter your gross montly income"
    let description2Text: String = "Do you want to PunchPad to calculate your net salary based on Polish tax law?"
    let paycheckText: String = "Gross paycheck"
    let netSalaryToggleText: String = "Calculate net salary"
    let localCurrencyCode: String = {
        return Locale.current.currency?.identifier ?? "USD"
    }()
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
                .foregroundStyle(Color.theme.blackLabel)
            
            TextField("", value: $viewModel.grossPayPerMonthText, format: .currency(code: localCurrencyCode))
                .accessibilityIdentifier(Identifier.TextFields.grossPaycheck.rawValue)
                .textFieldStyle(.greenBordered)
                
            
        }
        .padding()
        .background()
        .cornerRadius(20)
    }
    var netSalaryToggle: some View {
        Toggle(netSalaryToggleText,
               isOn: $viewModel.settingsStore.isCalculatingNetPay)
        .foregroundColor(.theme.blackLabel)
        .tint(.theme.primary)
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
            self._vm = StateObject(wrappedValue: 
                                    OnboardingViewModel(notificationService: container.notificationService,
                                                        settingsStore: container.settingsStore)
            )
        }
        
        var body: some View {
            ZStack {
                BackgroundFactory.buildSolidColor()
                OnboardingSalaryView(viewModel: vm)
                VStack {
                    Spacer()
                    Button("Preview button") {
                        
                    }
                    .buttonStyle(.confirming)
                        .padding(30)
                }
            }
        }
    }
    static var previews: some View {
        PreviewContainerView()
    }
}

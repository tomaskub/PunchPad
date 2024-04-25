//
//  OnboardingSalaryView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 06/11/2023.
//

import SwiftUI
import ThemeKit

struct OnboardingSalaryView: View {
    private let localCurrencyCode: String = {
        Locale.current.currency?.identifier ?? "USD"
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
    
    private var title: some View {
        TextFactory.buildTitle(Strings.titleText)
    }
    private var description1: some View {
        TextFactory.buildDescription(Strings.description1Text)
    }
    private var description2: some View {
        TextFactory.buildDescription(Strings.description2Text)
    }
    private var grossPaycheckTextField: some View {
        HStack {
            Text(Strings.paycheckText)
                .foregroundStyle(Color.theme.blackLabel)
            
            TextField("", value: $viewModel.grossPayPerMonthText, format: .currency(code: localCurrencyCode))
                .accessibilityIdentifier(Identifier.TextFields.grossPaycheck.rawValue)
                .textFieldStyle(.greenBordered)
                
            
        }
        .padding()
        .background()
        .cornerRadius(20)
    }
    private var netSalaryToggle: some View {
        Toggle(Strings.netSalaryToggleText,
               isOn: $viewModel.settingsStore.isCalculatingNetPay)
        .foregroundColor(.theme.blackLabel)
        .tint(.theme.primary)
        .accessibilityIdentifier(Identifier.Toggles.calculateNetSalary.rawValue)
        .padding()
        .background()
        .cornerRadius(20)
    }
}

//MARK: - Localization
extension OnboardingSalaryView: Localized {
    struct Strings {
        static let titleText = Localization.OnboardingSalaryScreen.salary
        static let description1Text = Localization.OnboardingSalaryScreen.letKnowIncome
        static let description2Text = Localization.OnboardingSalaryScreen.wantTocalculateNetSalaru
        static let paycheckText = Localization.OnboardingSalaryScreen.grossPaycheck
        static let netSalaryToggleText = Localization.OnboardingSalaryScreen.calculateNetSalary
    }
}

struct OnboardingSalary_Preview: PreviewProvider {
    private struct PreviewContainerView: View {
        @StateObject private var vm: OnboardingViewModel
        private let container: PreviewContainer
        @Environment(\.colorScheme) private var colorScheme
        
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

//
//  SettingsView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI
import NavigationKit
import ThemeKit

struct SettingsView: View {
    private typealias Identifier = ScreenIdentifier.SettingsView
    @StateObject private var viewModel: SettingsViewModel
    @State private var isShowingWorkTimeEditor: Bool = false
    @State private var isShowingOvertimeEditor: Bool = false
    private let navigationTitle: AttributedString = {
        var result = AttributedString("Settings")
        result.font = .title.weight(.medium)
        result.foregroundColor = .theme.black
        return result
    }()
    private let trashIconName = "trash"
    private let arrowCounterClockwiseIconName = "arrow.counterclockwise"
    private let alertTitle: String = "PunchPad needs permission to show notifications"
    private let alertMessage: String = "You need to allow for notification in settings"
    private let alertButtonText: String = "OK"
    private let hoursPickerText: String = "Hours"
    private let minutesPickerText: String = "Minutes"
    private let timerLengthButtonText: String = "Set timer length"
    private let overtimeLengthButtonText: String = "Maximum overtime allowed"
    private let clearDataText: String = "Clear all saved data"
    private let resetPreferencesText: String = "Reset preferences"
    private let keepLogingOvertimeText: String = "Keep logging overtime"
    private let grossPaycheckText: String = "Gross paycheck"
    private let calculateNetPayText: String = "Calculate net pay"
    private let colorSchemeText: String = "Color scheme"
    private let colorSchemeDarkText: String = "Dark"
    private let colorSchemeLightText: String = "Light"
    private let colorSchemeSystemText: String = "System"
    private let currencyText: String = "PLN"
    private let notificationsText: String = "Send notification on finish"
    private let timerSettingsHeaderText: String = "Timer settings"
    private let overtimeSettingsHeaderText: String = "Overtime"
    private let paycheckSettingsText: String = "Paycheck calculation"
    private let userDataSettingsText: String = "User data"
    private let appearanceText: String = "Appearance"
    private var currencyCode: String {
        let locale = Locale.current
        return locale.currencySymbol ?? "PLN"
    }
    
    init(viewModel: SettingsViewModel) {
        self._viewModel = StateObject.init(wrappedValue: viewModel)
    }
}

// MARK: - Body
extension SettingsView {
    var body: some View {
        ZStack{
            background
            List {
                Section {
                    timerSettings
                    
                    makeToggleRow(notificationsText,
                                  isOn: $viewModel.settingsStore.isSendingNotification,
                                  identifier: .sendNotificationsOnFinish
                    )
                } header: {
                    TextFactory.buildSectionHeader(timerSettingsHeaderText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.timerSettings.rawValue)
                }
                .listRowBackground(Color.theme.white)
                Section {
                    makeToggleRow(keepLogingOvertimeText,
                                  isOn: $viewModel.settingsStore.isLoggingOvertime,
                                  identifier: .keepLoggingOvertime
                    )
                    overtimeSettings
                } header: {
                    TextFactory.buildSectionHeader(overtimeSettingsHeaderText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.overtimeSettings.rawValue)
                }
                .listRowBackground(Color.theme.white)
                Section {
                    grossPaycheckRow
                    
                    makeToggleRow(calculateNetPayText, isOn: $viewModel.settingsStore.isCalculatingNetPay,
                                  identifier: .calculateNetPay
                    )
                } header: {
                    TextFactory.buildSectionHeader(paycheckSettingsText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.paycheckCalculation.rawValue)
                }
                .listRowBackground(Color.theme.white)
                Section {
                    clearDataButton
                    resetPreferencesButton
                } header: {
                    TextFactory.buildSectionHeader(userDataSettingsText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.userData.rawValue)
                }
                .listRowBackground(Color.theme.white)
            }
            .scrollContentBackground(.hidden)
            .listRowSeparatorTint(.theme.primary)
            
        }
        .navigationBarTitle(navigationTitle)
        .navigationBarBackButtonColor(color: .theme.black)
        .alert(alertTitle,
               isPresented: $viewModel.shouldShowNotificationDeniedAlert) {
            Button(alertButtonText) {
                viewModel.shouldShowNotificationDeniedAlert = false
            }
        } message: {
            Text(alertMessage)
        }
    }
}

// MARK: - View Components
private extension SettingsView {
    var timerSettings: some View {
        Group {
            makeChevronListButton(timerLengthButtonText,
                                  chevronOrientation: isShowingWorkTimeEditor,
                                  accessibilityIdentifier: .setTimerLength) {
                withAnimation(.spring()) {
                    isShowingWorkTimeEditor.toggle()
                }
            }
            if isShowingWorkTimeEditor {
                makePickerRow(hours: $viewModel.timerHours,
                              minutes: $viewModel.timerMinutes,
                              hoursAccessibilityIdentifier: .timeHoursPicker,
                              minutesAccessibilityIdentifier: .timeMinutesPicker
                )
            }
        }
    }
    
    var overtimeSettings: some View {
        Group {
            makeChevronListButton(overtimeLengthButtonText,
                                  chevronOrientation: isShowingOvertimeEditor,
                                  accessibilityIdentifier: .setOvertimeLength) {
                withAnimation(.spring()) {
                    isShowingOvertimeEditor.toggle()
                }
            }
            if isShowingOvertimeEditor {
                makePickerRow(hours: $viewModel.overtimeHours,
                              minutes: $viewModel.overtimeMinutes,
                              hoursAccessibilityIdentifier: .overtimeHoursPicker,
                              minutesAccessibilityIdentifier: .overtimeMinutesPicker
                )
            }
        }
    }
    
    var grossPaycheckRow: some View {
        HStack {
            Text(grossPaycheckText)
                .foregroundStyle(Color.theme.blackLabel)
            TextField(String(),
                      value: $viewModel.grossPayPerMonth,
                      format: .currency(code: currencyCode)
            )
            .foregroundColor(.theme.blackLabel)
            .textFieldStyle(.greenBordered)
        }
    }
    
    var clearDataButton: some View {
        makeListButton(clearDataText,
                       systemName: trashIconName,
                       iconForegroundColor: .theme.redLabel,
                       accessibilityIdentifier: Identifier.ButtonCells.clearAllSavedData.rawValue) {
            viewModel.deleteAllData()
        }
    }
    
    var resetPreferencesButton: some View {
        makeListButton(resetPreferencesText,
                       systemName: arrowCounterClockwiseIconName,
                       iconForegroundColor: .theme.redLabel,
                       accessibilityIdentifier: Identifier.ButtonCells.resetPreferences.rawValue) {
            viewModel.resetUserDefaults()
        }
    }
    
    var background: some View {
        BackgroundFactory.buildSolidColor(.theme.tertiary)
    }
}

// MARK: - View Builders
private extension SettingsView {
    @ViewBuilder
    private func makeChevronListButton(_ text: String, chevronOrientation: Bool, accessibilityIdentifier: Identifier.ExpandableCells? = nil, onTap: @escaping () -> Void) -> some View {
        HStack {
            Text(text)
                .foregroundStyle(Color.theme.blackLabel)
            Spacer()
            Image(systemName: chevronOrientation ? "chevron.up" : "chevron.down")
        }
        .contentShape(Rectangle())
        .ifLet(accessibilityIdentifier) { view, identifier in
            view.accessibilityIdentifier(identifier.rawValue)
        }
        .onTapGesture {
            onTap()
        }
    }
    @ViewBuilder
    private func makeListButton(_ text: String, systemName: String, iconForegroundColor: Color? = nil, accessibilityIdentifier: String? = nil, onTap: @escaping () -> Void) -> some View {
        HStack {
            Text(text)
                .foregroundStyle(Color.theme.blackLabel)
            Spacer()
            Image(systemName: systemName)
                .ifLet(iconForegroundColor) { image, color in
                    image.foregroundColor(color)
                }
        }
        .contentShape(Rectangle())
        .ifLet(accessibilityIdentifier) { view, identifier in
            view.accessibilityIdentifier(identifier)
        }
        .onTapGesture {
            onTap()
        }
    }
    
    @ViewBuilder
    private func makeToggleRow(_ text: String, isOn value: Binding<Bool>, identifier: Identifier.ToggableCells) -> some View {
        Toggle(text, isOn: value)
            .foregroundStyle(Color.theme.blackLabel)
            .tint(.theme.primary)
            .accessibilityIdentifier(identifier.rawValue)
    }
    
    
    @ViewBuilder
    private func makePickerRow(hours: Binding<Int>, minutes: Binding<Int>, hoursAccessibilityIdentifier: Identifier.Pickers? = nil, minutesAccessibilityIdentifier: Identifier.Pickers? = nil) -> some View {
        HStack {
            VStack {
                Text(hoursPickerText)
                    .foregroundColor(.theme.primary)
                
                Picker(hoursPickerText, selection: hours) {
                    ForEach(0..<25) { i in
                        Text("\(i)").tag(i)
                            .foregroundColor(.theme.primary)
                    }
                }
                .pickerStyle(.wheel)
                .ifLet(hoursAccessibilityIdentifier) { picker, identifier in
                    picker
                        .accessibilityIdentifier(identifier.rawValue)
                }
            }
            VStack {
                Text(minutesPickerText)
                    .foregroundColor(.theme.primary)
                
                Picker(minutesPickerText, selection: minutes) {
                    ForEach(0..<60) { i in
                        Text("\(i)").tag(i)
                            .foregroundColor(.theme.primary)
                    }
                }
                .pickerStyle(.wheel)
                .ifLet(minutesAccessibilityIdentifier) { picker, identifier in
                    picker
                        .accessibilityIdentifier(identifier.rawValue)
                }
            }
        }
    }
}

#Preview("SettingsView") {
    struct ContainerView: View {
        private let container = PreviewContainer()
        var body: some View {
            SettingsView(viewModel: 
                            SettingsViewModel(dataManger: container.dataManager,
                                              notificationService: container.notificationService,
                                              settingsStore: container.settingsStore)
            )
        }
    }
    return ContainerView()
}

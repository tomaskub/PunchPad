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
        var result = AttributedString(Strings.title)
        result.font = .title.weight(.medium)
        result.foregroundColor = .theme.black
        return result
    }()
    private let trashIconName = "trash"
    private let arrowCounterClockwiseIconName = "arrow.counterclockwise"
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
                    
                    makeToggleRow(Strings.notificationsText,
                                  isOn: $viewModel.settingsStore.isSendingNotification,
                                  identifier: .sendNotificationsOnFinish
                    )
                } header: {
                    TextFactory.buildSectionHeader(Strings.timerSettingsHeaderText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.timerSettings.rawValue)
                }
                .listRowBackground(Color.theme.white)
                Section {
                    makeToggleRow(Strings.keepLogingOvertimeText,
                                  isOn: $viewModel.settingsStore.isLoggingOvertime,
                                  identifier: .keepLoggingOvertime
                    )
                    overtimeSettings
                } header: {
                    TextFactory.buildSectionHeader(Strings.overtimeSettingsHeaderText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.overtimeSettings.rawValue)
                }
                .listRowBackground(Color.theme.white)
                Section {
                    grossPaycheckRow
                    
                    makeToggleRow(Strings.calculateNetPayText,
                                  isOn: $viewModel.settingsStore.isCalculatingNetPay,
                                  identifier: .calculateNetPay
                    )
                } header: {
                    TextFactory.buildSectionHeader(Strings.paycheckSettingsText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.paycheckCalculation.rawValue)
                }
                .listRowBackground(Color.theme.white)
                Section {
                    clearDataButton
                    resetPreferencesButton
                } header: {
                    TextFactory.buildSectionHeader(Strings.userDataSettingsText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.userData.rawValue)
                }
                .listRowBackground(Color.theme.white)
            }
            .scrollContentBackground(.hidden)
            .listRowSeparatorTint(.theme.primary)
            
        }
        .navigationBarTitle(navigationTitle)
        .navigationBarBackButtonColor(color: .theme.black)
        .alert(Strings.alertTitle,
               isPresented: $viewModel.shouldShowNotificationDeniedAlert) {
            Button(Strings.alertButtonText) {
                viewModel.shouldShowNotificationDeniedAlert = false
            }
        } message: {
            Text(Strings.alertMessage)
        }
    }
}

// MARK: - View Components
private extension SettingsView {
    var timerSettings: some View {
        Group {
            makeChevronListButton(Strings.timerLengthButtonText,
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
            makeChevronListButton(Strings.overtimeLengthButtonText,
                                  chevronOrientation: isShowingOvertimeEditor,
                                  accessibilityIdentifier: .setOvertimeLength) {
                withAnimation(.spring()) {
                    isShowingOvertimeEditor.toggle()
                }
            }
            if isShowingOvertimeEditor {
                makePickerRow(
                    hours: $viewModel.overtimeHours,
                    minutes: $viewModel.overtimeMinutes,
                    hoursAccessibilityIdentifier: .overtimeHoursPicker,
                    minutesAccessibilityIdentifier: .overtimeMinutesPicker
                )
            }
        }
    }
    
    var grossPaycheckRow: some View {
        HStack {
            Text(Strings.grossPaycheckText)
                .foregroundStyle(Color.theme.blackLabel)
            TextField(String(),
                      value: $viewModel.grossPayPerMonth,
                      format: .currency(code: currencyCode)
            )
            .foregroundColor(.theme.blackLabel)
            .textFieldStyle(.greenBordered)
            .accessibilityIdentifier(Identifier.TextFields.grossPay)
        }
    }
    
    var clearDataButton: some View {
        makeListButton(Strings.clearDataText,
                       systemName: trashIconName,
                       iconForegroundColor: .theme.redLabel,
                       accessibilityIdentifier: Identifier.ButtonCells.clearAllSavedData.rawValue) {
            viewModel.deleteAllData()
        }
    }
    
    var resetPreferencesButton: some View {
        makeListButton(Strings.resetPreferencesText,
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
            .accessibilityIdentifier(identifier)
    }
    
    
    @ViewBuilder
    private func makePickerRow(hours: Binding<Int>, minutes: Binding<Int>, hoursAccessibilityIdentifier: Identifier.Pickers? = nil, minutesAccessibilityIdentifier: Identifier.Pickers? = nil) -> some View {
        HStack {
            VStack {
                Text(Strings.hoursPickerText)
                    .foregroundColor(.theme.primary)
                
                Picker(Strings.hoursPickerText, selection: hours) {
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
                Text(Strings.minutesPickerText)
                    .foregroundColor(.theme.primary)
                
                Picker(Strings.minutesPickerText, selection: minutes) {
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

//MARK: -Localization
extension SettingsView: Localized {
    struct Strings {
        static let title = Localization.SettingsScreen.settings
        static let alertTitle = Localization.SettingsScreen.needsPermissionToShowNotifications
        static let alertMessage = Localization.SettingsScreen.youNeedToAllowForNotifications
        static let alertButtonText = Localization.Common.ok.uppercased()
        static let hoursPickerText = Localization.Common.hours.capitalized
        static let minutesPickerText = Localization.Common.minutes.capitalized
        static let timerLengthButtonText = Localization.SettingsScreen.setTimerLength
        static let overtimeLengthButtonText = Localization.SettingsScreen.maximumOvertimeAllowed
        static let clearDataText = Localization.SettingsScreen.clearAllSavedData
        static let resetPreferencesText = Localization.SettingsScreen.resetPreferences
        static let keepLogingOvertimeText = Localization.SettingsScreen.keepLogingOvertime
        static let grossPaycheckText = Localization.SettingsScreen.grossPaycheck
        static let calculateNetPayText = Localization.SettingsScreen.calculateNetPay
        static let colorSchemeText = Localization.SettingsScreen.colorScheme
        static let colorSchemeDarkText = Localization.SettingsScreen.dark
        static let colorSchemeLightText = Localization.SettingsScreen.light
        static let colorSchemeSystemText = Localization.SettingsScreen.system
        static let notificationsText = Localization.SettingsScreen.sendNotificationsOnFinish
        static let timerSettingsHeaderText = Localization.SettingsScreen.timerSettings
        static let overtimeSettingsHeaderText = Localization.Common.overtime.capitalized
        static let paycheckSettingsText = Localization.SettingsScreen.paycheckCalculation
        static let userDataSettingsText = Localization.SettingsScreen.userData
        static let appearanceText = Localization.SettingsScreen.appearance
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

//
//  SettingsView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI
import NavigationKit

struct SettingsView: View {
    private typealias Identifier = ScreenIdentifier.SettingsView
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: SettingsViewModel
    @State private var isShowingWorkTimeEditor: Bool = false
    @State private var isShowingOvertimeEditor: Bool = false
    
    init(viewModel: SettingsViewModel) {
        self._viewModel = StateObject.init(wrappedValue: viewModel)
    }
    let alertTitle: String = "PunchPad needs permission to show notifications"
    let alertMessage: String = "You need to allow for notification in settings"
    let alertButtonText: String = "OK"
    let navigationTitleText: String = "Settings"
    let hoursPickerText: String = "Hours"
    let minutesPickerText: String = "Minutes"
    let timerLengthButtonText: String = "Set timer length"
    let overtimeLengthButtonText: String = "Maximum overtime allowed"
    let clearDataText: String = "Clear all saved data"
    let resetPreferencesText: String = "Reset preferences"
    let keepLogingOvertimeText: String = "Keep logging overtime"
    let grossPaycheckText: String = "Gross paycheck"
    let calculateNetPayText: String = "Calculate net pay"
    let colorSchemeText: String = "Color scheme"
    let colorSchemeDarkText: String = "Dark"
    let colorSchemeLightText: String = "Light"
    let colorSchemeSystemText: String = "System"
    let currencyText: String = "PLN"
    let notificationsText: String = "Send notification on finish"
    // header texts
    let timerSettingsHeaderText: String = "Timer settings"
    let overtimeSettingsHeaderText: String = "Overtime"
    let paycheckSettingsText: String = "Paycheck calculation"
    let userDataSettingsText: String = "User data"
    let appearanceText: String = "Appearance"
    
    var currencyCode: String {
        let locale = Locale.current
        return locale.currencySymbol ?? "PLN"
    }
}

// MARK: BODY
extension SettingsView {
    var body: some View {
        ZStack{
            //BACKGROUND
            background
            //CONTENT
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
                } // END OF SECTION
                Section {
                    makeToggleRow(keepLogingOvertimeText,
                                  isOn: $viewModel.settingsStore.isLoggingOvertime,
                                  identifier: .keepLoggingOvertime
                    )
                    overtimeSettings
                } header: {
                    TextFactory.buildSectionHeader(overtimeSettingsHeaderText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.overtimeSettings.rawValue)
                } // END OF SECTION
                
                Section {
                    grossPaycheckRow
                    
                    makeToggleRow(calculateNetPayText, isOn: $viewModel.settingsStore.isCalculatingNetPay,
                                  identifier: .calculateNetPay
                    )
                } header: {
                    TextFactory.buildSectionHeader(paycheckSettingsText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.paycheckCalculation.rawValue)
                } // END OF SECTION
                
                Section {
                    clearDataButton
                    resetPreferencesButton
                } header: {
                    TextFactory.buildSectionHeader(userDataSettingsText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.userData.rawValue)
                } // END OF SECTION
                
//                appearanceSection
            } // END OF LIST
            .scrollContentBackground(.hidden)
            .listRowSeparatorTint(.theme.primary)
            
        } // END OF ZSTACK
        .navigationBarTitle("Settings")
        .alert(alertTitle,
               isPresented: $viewModel.shouldShowNotificationDeniedAlert) {
            Button(alertButtonText) {
                viewModel.shouldShowNotificationDeniedAlert = false 
            }
        } message: {
            Text(alertMessage)
        }

    } // END OF BODY
    
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
            } // END OF IF
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
            .textFieldStyle(.greenBordered)
        }
    }
    
    var clearDataButton: some View {
        makeListButton(clearDataText,
                       systemName: "trash",
                       iconForegroundColor: .theme.redLabel,
                       accessibilityIdentifier: Identifier.ButtonCells.clearAllSavedData.rawValue) {
            viewModel.deleteAllData()
        }
    }
    
    var resetPreferencesButton: some View {
        makeListButton(resetPreferencesText,
                       systemName: "arrow.counterclockwise",
                       iconForegroundColor: .theme.redLabel,
                       accessibilityIdentifier: Identifier.ButtonCells.resetPreferences.rawValue) {
            viewModel.resetUserDefaults()
        }

    }
    
    //Removed color scheme section - crashes the app and right now colors are not supported
    /*
    var appearanceSection: some View {
        Section {
            VStack{
                Text(colorSchemeText)
                Picker("appearance", selection: $viewModel.settingsStore.savedColorScheme) {
                    Text(colorSchemeSystemText)
                        .tag(nil as ColorScheme?)
                        .accessibilityIdentifier(Identifier.SegmentedControlButtons.system.rawValue)
                    Text(colorSchemeDarkText)
                        .tag(ColorScheme.dark)
                        .accessibilityIdentifier(Identifier.SegmentedControlButtons.dark.rawValue)
                    Text(colorSchemeLightText)
                        .tag(ColorScheme.light)
                        .accessibilityIdentifier(Identifier.SegmentedControlButtons.light.rawValue)
                } // END OF PICKER
                .accessibilityIdentifier(Identifier.Pickers.appearancePicker.rawValue)
                .pickerStyle(.segmented)
            } // END OF VSTACK
        } header: {
            TextFactory.buildSectionHeader(appearanceText)
                .accessibilityIdentifier(Identifier.SectionHeaders.appearance.rawValue)
        } // END OF SECTION
         */
}

// MARK: VIEWBUILDERS
extension SettingsView {
    @ViewBuilder
    private func makeChevronListButton(_ text: String, chevronOrientation: Bool, accessibilityIdentifier: Identifier.ExpandableCells? = nil, onTap: @escaping () -> Void) -> some View {
        HStack {
            Text(text)
                .foregroundStyle(Color.theme.blackLabel)
            Spacer()
            Image(systemName: chevronOrientation ? "chevron.up" : "chevron.down")
        } // END OF HSTACK
        .contentShape(Rectangle())
        .ifLet(accessibilityIdentifier) { view, identifier in
            view.accessibilityIdentifier(identifier.rawValue)
        }
        .onTapGesture {
            onTap()
        } // END OF TAP GESTURE
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
        } // END OF HSTACK
        .contentShape(Rectangle())
        .ifLet(accessibilityIdentifier) { view, identifier in
            view.accessibilityIdentifier(identifier)
        }
        .onTapGesture {
            onTap()
        } // END OF TAP GESTURE
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

//MARK: VIEW COMPONENTS
extension SettingsView {
    var background: some View {
        BackgroundFactory.buildSolidColor(.theme.tertiary)
    }
}
struct SettingsView_Previews: PreviewProvider {
    private struct ContainerView: View {
        @StateObject private var container = Container()
        var body: some View {
            SettingsView(viewModel: 
                            SettingsViewModel(dataManger: container.dataManager,
                                              notificationService: container.notificationService,
                                              settingsStore: container.settingsStore)
            )
        }
    }
    static var previews: some View {
        ContainerView()
    }
        
}

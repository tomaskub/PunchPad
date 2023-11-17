//
//  SettingsView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI

struct SettingsView: View {
    private typealias Identifier = ScreenIdentifier.SettingsView
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: SettingsViewModel
    @State private var isShowingWorkTimeEditor: Bool = false
    @State private var isShowingOvertimeEditor: Bool = false
    
    init(viewModel: SettingsViewModel) {
        self._viewModel = StateObject.init(wrappedValue: viewModel)
    }
    
    // MARK: TEXT PROPERTIES
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
    // header texts
    let timerSettingsHeaderText: String = "Timer settings"
    let overtimeSettingsHeaderText: String = "Overtime"
    let paycheckSettingsText: String = "Paycheck calculation"
    let userDataSettingsText: String = "User data"
    let appearanceText: String = "Appearance"
    
    // MARK: BODY
    var body: some View {
        ZStack{
            //BACKGROUND
            background
            //CONTENT
            List {
                Section {
                    makeChevronListButton(timerLengthButtonText,
                                          chevronOrientation: isShowingWorkTimeEditor,
                                          accessibilityIdentifier: Identifier.ExpandableCells.setTimerLength.rawValue) {
                        withAnimation(.spring()) {
                            isShowingWorkTimeEditor.toggle()
                        }
                    }
                    if isShowingWorkTimeEditor {
                        makePickerRow(hours: $viewModel.timerHours,
                                      minutes: $viewModel.timerMinutes,
                                      hoursAccessibilityIdentifier: Identifier.Pickers.timeHoursPicker.rawValue,
                                      minutesAccessibilityIdentifier: Identifier.Pickers.timeMinutesPicker.rawValue
                        )
                    } // END OF IF
                    
                    Toggle(isOn: $viewModel.settingsStore.isSendingNotification) {
                        Text("Send notification on finish")
                    } // END OF TOGGLE
                    .accessibilityIdentifier(Identifier.ToggableCells.sendNotificationsOnFinish.rawValue)
                } header: {
                    makeHeader(timerSettingsHeaderText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.timerSettings.rawValue)
                } // END OF SECTION
                Section {
                    
                    Toggle(isOn: $viewModel.settingsStore.isLoggingOvertime) {
                        Text("Keep loging overtime")
                    }
                    .accessibilityIdentifier(Identifier.ToggableCells.keepLoggingOvertime.rawValue)
                    
                    makeChevronListButton(overtimeLengthButtonText,
                                          chevronOrientation: isShowingOvertimeEditor,
                                          accessibilityIdentifier: Identifier.ExpandableCells.setOvertimeLength.rawValue) {
                        withAnimation(.spring()) {
                            isShowingOvertimeEditor.toggle()
                        }
                    }
                    
                    if isShowingOvertimeEditor {
                        makePickerRow(hours: $viewModel.overtimeHours,
                                      minutes: $viewModel.overtimeMinutes,
                                      hoursAccessibilityIdentifier: Identifier.Pickers.overtimeHoursPicker.rawValue,
                                      minutesAccessibilityIdentifier: Identifier.Pickers.overtimeMinutesPicker.rawValue
                        )
                    }
                } header: {
                    makeHeader(overtimeSettingsHeaderText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.overtimeSettings.rawValue)
                } // END OF SECTION
                Section {
                    HStack {
                        Text(grossPaycheckText)
                        TextField(String(), text: $viewModel.grossPayPerMonthText)
                            .accessibilityIdentifier(Identifier.TextFields.grossPay.rawValue)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                        Text(currencyText)
                    }
                    Toggle(calculateNetPayText, isOn: $viewModel.settingsStore.isCalculatingNetPay)
                        .accessibilityIdentifier(Identifier.ToggableCells.calculateNetPay.rawValue)
                } header: {
                    makeHeader(paycheckSettingsText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.paycheckCalculation.rawValue)
                } // END OF SECTION
                Section {
                    makeListButton(clearDataText,
                                   systemName: "trash",
                                   iconForegroundColor: .red,
                                   accessibilityIdentifier: Identifier.ButtonCells.clearAllSavedData.rawValue) {
                        viewModel.deleteAllData()
                    }
                    makeListButton(resetPreferencesText,
                                   systemName: "arrow.counterclockwise",
                                   iconForegroundColor: .red,
                                   accessibilityIdentifier: Identifier.ButtonCells.resetPreferences.rawValue) {
                        viewModel.resetUserDefaults()
                    }
                } header: {
                    makeHeader("User data")
                        .accessibilityIdentifier(Identifier.SectionHeaders.userData.rawValue)
                } // END OF SECTION
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
                    makeHeader(appearanceText)
                        .accessibilityIdentifier(Identifier.SectionHeaders.appearance.rawValue)
                } // END OF SECTION
            } // END OF LIST
            .scrollContentBackground(.hidden)
            
        } // END OF ZSTACK
        .navigationTitle(navigationTitleText)
    } // END OF BODY
    var background: some View {
        BackgroundFactory.buildSolidColor()
            .opacity(0.5)
    }
}
// MARK: VIEWBUILDERS
extension SettingsView {
    @ViewBuilder
    private func makeChevronListButton(_ text: String, chevronOrientation: Bool, accessibilityIdentifier: String? = nil, onTap: @escaping () -> Void) -> some View {
        HStack {
            Text(text)
            Spacer()
            Image(systemName: chevronOrientation ? "chevron.up" : "chevron.down")
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
    private func makeListButton(_ text: String, systemName: String, iconForegroundColor: Color? = nil, accessibilityIdentifier: String? = nil, onTap: @escaping () -> Void) -> some View {
        HStack {
            Text(text)
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
    private func makeHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .foregroundColor(.primary)
    }
    
    @ViewBuilder
    private func makePickerRow(hours: Binding<Int>, minutes: Binding<Int>, hoursAccessibilityIdentifier: String? = nil, minutesAccessibilityIdentifier: String? = nil) -> some View {
        HStack {
            VStack {
                Text(hoursPickerText)
                Picker(hoursPickerText, selection: hours) {
                    ForEach(0..<25) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .pickerStyle(.wheel)
                .ifLet(hoursAccessibilityIdentifier) { picker, identifier in
                    picker
                        .accessibilityIdentifier(identifier)
                }
            }
            VStack {
                Text(minutesPickerText)
                Picker(minutesPickerText, selection: minutes) {
                    ForEach(0..<60) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .pickerStyle(.wheel)
                .ifLet(minutesAccessibilityIdentifier) { picker, identifier in
                    picker
                        .accessibilityIdentifier(identifier)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    private struct ContainerView: View {
        @StateObject private var container = Container()
        var body: some View {
            NavigationView {
                SettingsView(viewModel: SettingsViewModel(dataManger: container.dataManager, settingsStore: container.settingsStore))
            }
        }
    }
    static var previews: some View {
        ContainerView()
    }
        
}

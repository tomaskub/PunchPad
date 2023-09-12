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
    @StateObject var viewModel = SettingsViewModel()
    
    init(viewModel: SettingsViewModel = SettingsViewModel()) {
        self._viewModel = StateObject.init(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack{
            //BACKGROUND
            GradientFactory.build(colorScheme: colorScheme)
            //CONTENT
            List {
                Section {
                    
                    HStack {
                        Text("Set timer length")
                        Spacer()
                        Image(systemName: viewModel.isShowingWorkTimeEditor ? "chevron.up" : "chevron.down")
                    } // END OF HSTACK
                    .accessibilityIdentifier(Identifier.ExpandableCells.setTimerLength.rawValue)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring()) {
                            viewModel.isShowingWorkTimeEditor.toggle()
                        }
                    } // END OF TAP GESTURE
                    
                    if viewModel.isShowingWorkTimeEditor {
                        timePickers
                    } // END OF IF
                    
                    Toggle(isOn: $viewModel.isSendingNotifications) {
                        Text("Send notification on finish")
                    } // END OF TOGGLE
                    .accessibilityIdentifier(Identifier.ToggableCells.sendNotificationsOnFinish.rawValue)
                } header: {
                    Text("Timer Settings")
                        .accessibilityIdentifier(Identifier.SectionHeaders.timerSettings.rawValue)
                } // END OF SECTION
                Section {
                    
                    Toggle(isOn: $viewModel.isLoggingOverTime) {
                        Text("Keep loging overtime")
                    }
                    .accessibilityIdentifier(Identifier.ToggableCells.keepLoggingOvertime.rawValue)
                    
                    HStack {
                        Text("Maximum overtime allowed")
                        Spacer()
                        Image(systemName: viewModel.isShowingOverTimeEditor ? "chevron.up" : "chevron.down")
                    } // END OF HSTACK
                    .accessibilityIdentifier(Identifier.ExpandableCells.setOvertimeLength.rawValue)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring()) {
                            viewModel.isShowingOverTimeEditor.toggle()
                        }
                    } // END OF TAP GESTURE
                    
                    if viewModel.isShowingOverTimeEditor {
                        overTimePickers
                    }
                } header: {
                    Text("Overtime")
                        .accessibilityIdentifier(Identifier.SectionHeaders.overtimeSettings.rawValue)
                } // END OF SECTION
                Section {
                    HStack {
                        Text("Gross paycheck")
                        TextField("Gross", text: $viewModel.grossPayPerMonthText)
                            .accessibilityIdentifier(Identifier.TextFields.grossPay.rawValue)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                        Text("PLN")
                    }
                    Toggle("Calculate net pay", isOn: $viewModel.calculateNetPaycheck)
                        .accessibilityIdentifier(Identifier.ToggableCells.calculateNetPay.rawValue)
                } header: {
                    Text("Paycheck calculation")
                        .accessibilityIdentifier(Identifier.SectionHeaders.paycheckCalculation.rawValue)
                } // END OF SECTION
                Section {
                    HStack {
                        Text("Clear all saved data")
                            Spacer()
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    } // END OF HSTACK
                    .contentShape(Rectangle())
                    .accessibilityIdentifier(Identifier.ButtonCells.clearAllSavedData.rawValue)
                    .onTapGesture {
                        viewModel.deleteAllData()
                    } // END OF TAP GESTURE
                    HStack {
                        Text("Reset preferences")
                        Spacer()
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.red)
                    } // END OF HSTACK
                    .contentShape(Rectangle())
                    .accessibilityIdentifier(Identifier.ButtonCells.resetPreferences.rawValue)
                    .onTapGesture {
                        viewModel.resetUserDefaults()
                    } // END OF TAP GESTURE
                } header: {
                    Text("User data")
                        .accessibilityIdentifier(Identifier.SectionHeaders.userData.rawValue)
                } // END OF SECTION
                Section {
                    VStack{
                        Text("Color scheme")
                        Picker("appearance", selection: $viewModel.preferredColorScheme) {
                            Text("System")
                                .tag("system")
                                .accessibilityIdentifier(Identifier.SegmentedControlButtons.system.rawValue)
                            Text("Dark")
                                .tag("dark")
                                .accessibilityIdentifier(Identifier.SegmentedControlButtons.dark.rawValue)
                            Text("Light")
                                .tag("light")
                                .accessibilityIdentifier(Identifier.SegmentedControlButtons.light.rawValue)
                        } // END OF PICKER
                        .accessibilityIdentifier(Identifier.Pickers.appearancePicker.rawValue)
                        .pickerStyle(.segmented)
                    } // END OF VSTACK
                } header: {
                    Text("Appearance")
                        .accessibilityIdentifier(Identifier.SectionHeaders.appearance.rawValue)
                } // END OF SECTION
            } // END OF LIST
            .foregroundColor(.primary)
            .scrollContentBackground(.hidden)
        } // END OF ZSTACK
    } // END OF BODY
    
    var timePickers: some View {
        HStack {
            VStack {
                Text("Hours")
                Picker("hours", selection: $viewModel.timerHours) {
                    ForEach(0..<25) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .accessibilityIdentifier(Identifier.Pickers.timeHoursPicker.rawValue)
                .pickerStyle(.wheel)
            }
            VStack {
                Text("Minutes")
                Picker("minutes", selection: $viewModel.timerMinutes) {
                    ForEach(0..<60) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .accessibilityIdentifier(Identifier.Pickers.timeMinutesPicker.rawValue)
                .pickerStyle(.wheel)
            }
        }
    }
    var overTimePickers: some View {
        HStack {
            VStack {
                Text("Hours")
                Picker("hours", selection: $viewModel.overtimeHours) {
                    ForEach(0..<25) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .accessibilityIdentifier(Identifier.Pickers.overtimeHoursPicker.rawValue)
                .pickerStyle(.wheel)
            }
            VStack {
                Text("Minutes")
                Picker("minutes", selection: $viewModel.overtimeMinutes) {
                    ForEach(0..<60) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .accessibilityIdentifier(Identifier.Pickers.overtimeMinutesPicker.rawValue)
                .pickerStyle(.wheel)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView().navigationTitle("Settings")
        }
    }
        
}

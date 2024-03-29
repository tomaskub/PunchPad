//
//  EditSheetView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/18/23.
//

import SwiftUI
import ThemeKit

struct EditSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: EditSheetViewModel
    @State private var isShowingOverrideControls: Bool = false
    private typealias Identifier = ScreenIdentifier.EditSheetView
    let regularTimeText: String = "Regular time"
    let overtimeText: String = "Overtime"
    let breaktimeText: String = "Break time"
    let titleText: String = "Edit entry"
    let timeIndicatorText: String = "work time"
    let overrideSettingsHeaderText: String = "Override settings"
    let startDateText: String = "Start"
    let finishDateText: String = "Finish"
    let saveButtonText: String = "save"
    let cancelButtonText: String = "cancel"
    let maximumOvertimeText = "Maximum overtime"
    let standardWorkTimeText = "Standard work time"
    let grossPayPerMonthText = "Gross pay per month"
    let calculateNetPayText = "Calculate net pay"
    let dateComponentFormatter = FormatterFactory.makeHourAndMinuteDateComponentFormatter()
} // END OF STRUCT

//MARK: BODY
extension EditSheetView {
    var body: some View {
        ZStack {
            background
            GeometryReader { proxy in
                ScrollViewReader { scrollProxy in
                    
                    ScrollView {
                        VStack {
                            title
                            infoSection
                            divider
                            dateControls
                            divider
                            overrideControls(scrollProxy)
                            Spacer()
                            editControls
                        }
                        .padding(.horizontal, 32)
                        .frame(minHeight: proxy.size.height)
                    }
                }
            }
            .padding(.top)
        } // END OF ZSTACK
    } // END OF BODY
}

//MARK: TIME INDICATOR & LABELS
extension EditSheetView {
    var infoSection: some View {
        Group {
            timeIndicator
                .padding(.bottom)
            HStack {
                regularTimeLabel
                Spacer()
                overtimeLabel
                Spacer()
                breakTimeLabel
            }
        }
    }
    var timeIndicator: some View {
        TimerIndicator(
            timerLabel: generateTimeIntervalLabel(value: viewModel.totalTimeInSeconds),
            firstProgress: viewModel.workTimeFraction,
            secondProgress: viewModel.overTimeFraction,
            useOnlyWorkLabel: true)
        .frame(width: 250, height: 250)
    }
    
    var overtimeLabel: some View {
            VStack {
                Text(generateTimeIntervalLabel(value: viewModel.overTimeInSeconds))
                    .font(.title)
                Text(overtimeText)
                    .font(.caption)
            }
            .foregroundColor(.theme.black)
    }
    
    var regularTimeLabel: some View {
            VStack {
                Text(generateTimeIntervalLabel(value: viewModel.workTimeInSeconds))
                    .font(.title)
                Text(regularTimeText)
                    .font(.caption)
            }
            .foregroundColor(.theme.black)
    }
    
    var breakTimeLabel: some View {
        VStack {
            Text(generateTimeIntervalLabel(value: viewModel.breakTime))
                .font(.title)
            Text(breaktimeText)
                .font(.caption)
        }
        .foregroundColor(.theme.black)
    }
    
    private func generateTimeIntervalLabel(value: TimeInterval) -> String {
        return dateComponentFormatter.string(from: value) ?? "00:00"
    }
}

//MARK: DATE CONTROLS
extension EditSheetView {
    @ViewBuilder
    var dateControls: some View {
        if !viewModel.shouldDisplayFullDates {
            sameDayDateControls
        } else {
            diffDayDateControls
        }
    }
    
    var diffDayDateControls: some View {
        Group {
            CustomDatePickerContainer(labelText: startDateText) {
                DatePicker(startDateText, selection: $viewModel.startDate, in: PartialRangeThrough(viewModel.finishDate))
                    .labelsHidden()
                    .accessibilityIdentifier(Identifier.DatePicker.startDate.rawValue)
            } trailing: {
               calendarToggable
            }
            .frame(height: 50)
            .padding(.top)
            .padding(.bottom, 2)
            
            CustomDatePickerContainer(labelText: finishDateText) {
                DatePicker(finishDateText, selection: $viewModel.finishDate, in: PartialRangeFrom(viewModel.startDate))
                    .labelsHidden()
                    .accessibilityIdentifier(Identifier.DatePicker.finishDate.rawValue)
            } trailing: {
                calendarToggable
            }
            .frame(height: 50)
            .padding(.bottom)
        }
        
    }
    
    var sameDayDateControls: some View {
        Group {
            CustomDatePickerContainer(labelText: "Date") {
                DatePicker(selection: $viewModel.startDate,
                           displayedComponents: .date) {
                    EmptyView()
                }
                           .labelsHidden()
            } trailing: {
                calendarToggable
            }
            .frame(height: 50)
            .padding(.top)
            .padding(.bottom, 2)
            HStack {
                CustomDatePickerContainer(labelText: startDateText) {
                    DatePicker(selection: $viewModel.startDate,
                               in: PartialRangeThrough(viewModel.finishDate),
                               displayedComponents: .hourAndMinute) {
                        EmptyView()
                    }
                               .labelsHidden()
                } trailing: {
                    imageClock
                }
                .frame(height: 50)
                CustomDatePickerContainer(labelText: finishDateText) {
                    DatePicker(selection: $viewModel.finishDate,
                               in: PartialRangeFrom(viewModel.startDate),
                               displayedComponents: .hourAndMinute) {
                        EmptyView()
                    }
                               .labelsHidden()
                } trailing: {
                    imageClock
                }
                .frame(height: 50)
            }
            .padding(.bottom)
        }
    }
}

//MARK: OVERRIDE SETTINGS CONTROLS
extension EditSheetView {
    @ViewBuilder
    func overrideControls(_ proxy: ScrollViewProxy) -> some View {
        overrideSettingsHeader(proxy)
        if isShowingOverrideControls {
            overrideContent
        }
         
    }
    
    @ViewBuilder func overrideSettingsHeader(_ proxy: ScrollViewProxy) -> some View {
        HStack {
            Image(systemName: isShowingOverrideControls ? "chevron.up" : "chevron.down")
                .foregroundColor(.theme.primary)
                .fontWeight(.bold)
                .onTapGesture {
                    Task {
                        let duration: TimeInterval = 0.1
                        await animate(duration: duration, animation: .spring(duration: duration)) {
                            isShowingOverrideControls.toggle()
                        }
                        
                        await animate(duration: duration, animation: .spring(duration: duration)) {
                            proxy.scrollTo("editControls", anchor: .top)
                        }
                    }
                }
            Text(overrideSettingsHeaderText)
                .font(.system(size: 24))
            Spacer()
        }
        .frame(height: 50)
    }
    
    var overrideContent: some View {
        Grid(alignment: .leading) {
            divider
            GridRow {
                Text(maximumOvertimeText)
                TimeIntervalPicker(buttonLabelText: generateTimeIntervalLabel(value: viewModel.currentMaximumOvertime),
                                   value: $viewModel.currentMaximumOvertime
                )
            }
            divider
            GridRow {
                Text(standardWorkTimeText)
                TimeIntervalPicker(buttonLabelText: generateTimeIntervalLabel(value: viewModel.currentStandardWorkTime),
                                   value: $viewModel.currentStandardWorkTime
                )
            }
            divider
            GridRow {
                Text(grossPayPerMonthText)
                TextField("PLN",
                          value: $viewModel.grossPayPerMonth,
                          format: .currency(code: "PLN"))
                .textFieldStyle(.roundedBorder)
                .foregroundColor(.black)
            }
            divider
            Toggle(isOn: $viewModel.calculateNetPay) {
                Text(calculateNetPayText)
             
            }
            .tint(.theme.primary)
            .padding(.trailing)
            divider
        }
        .foregroundStyle(Color.theme.blackLabel)
    }
}

//MARK: SAVE CONTROLS
extension EditSheetView {
    var editControls: some View {
        Group {
            HStack {
                Button(cancelButtonText.uppercased()) {
                    dismiss()
                }
                .buttonStyle(CancelButtonStyle())
                .accessibilityIdentifier(Identifier.Button.cancel.rawValue)
                
                Button(saveButtonText.uppercased()) {
                    viewModel.saveEntry()
                    dismiss()
                }
                .buttonStyle(ConfirmButtonStyle())
                .accessibilityIdentifier(Identifier.Button.save.rawValue)
            } // END OF HSTACK
            .id("editControls")
        }
    }
}

//MARK: VIEW COMPONENTS
extension EditSheetView {
    var title: some View {
        HStack {
            Text(titleText)
                .font(.title)
                .foregroundColor(.theme.black)
            Spacer()
        }
        .padding(.top)
        
    }
    
    var divider: some View {
        VerticalDivider()
            .stroke(style: .init(lineWidth: 1, dash: [2]))
            .foregroundColor(.theme.primary)
            .frame(height: 1)
    }
    
    var imageClock: some View {
        Image(systemName: "clock")
            .font(.title)
            .foregroundColor(.theme.primary)
    }
    
    var calendarToggable: some View {
        imageCalendar
            .onTapGesture {
                withAnimation {
                    viewModel.shouldDisplayFullDates.toggle()
                }
            }
    }
    
    var imageCalendar: some View {
        Image(systemName: "calendar")
            .font(.title)
            .foregroundColor(.theme.primary)
    }
    
    var background: some View {
        BackgroundFactory.buildSolidColor(.theme.white)
    }
}

#Preview("Signle date controls") {
    struct ContainerView: View {
        @StateObject private var container: Container = .init()
        private let entry: Entry = {
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let startDate = Calendar.current.date(byAdding: .hour, value: 6, to: startOfDay)!
            let finishDate = Calendar.current.date(byAdding: .minute,
                                                   value: 9 * 60 + 30,
                                                   to: startDate)!
            return Entry(startDate: startDate,
                         finishDate: finishDate,
                         workTimeInSec: 4*3600 + 20 * 60,
                         overTimeInSec: 0,
                         maximumOvertimeAllowedInSeconds: 5*3600,
                         standardWorktimeInSeconds: 8*3600,
                         grossPayPerMonth: 10000,
                         calculatedNetPay: nil)
        }()
        var body: some View {
            ZStack {
                BackgroundFactory.buildSolidColor()
            }
            .sheet(isPresented: .constant(true)){
                EditSheetView(viewModel:
                                EditSheetViewModel(dataManager: container.dataManager,
                                                   settingsStore: container.settingsStore,
                                                   payService: container.payManager,
                                                   entry: entry)
                )
            }
        }
    }
    
    return ContainerView()
    
} // END OF PREVIEW

#Preview("Two date controls") {
    struct ContainerView: View {
        @StateObject private var container: Container = .init()
        private let entry: Entry = {
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let startDate = Calendar.current.date(byAdding: .hour, value: 16, to: startOfDay)!
            let finishDate = Calendar.current.date(byAdding: .minute,
                                                   value: 9 * 60 + 30,
                                                   to: startDate)!
            return Entry(startDate: startDate,
                         finishDate: finishDate,
                         workTimeInSec: 4*3600,
                         overTimeInSec: 0,//3600 + 1800,
                         maximumOvertimeAllowedInSeconds: 5*3600,
                         standardWorktimeInSeconds: 8*3600,
                         grossPayPerMonth: 10000,
                         calculatedNetPay: nil)
        }()
        var body: some View {
            ZStack {
                BackgroundFactory.buildSolidColor()
            }
            .sheet(isPresented: .constant(true)){
                EditSheetView(viewModel:
                                EditSheetViewModel(dataManager: container.dataManager,
                                                   settingsStore: container.settingsStore,
                                                   payService: container.payManager,
                                                   entry: entry)
                )
            }
        }
    }
    
    return ContainerView()
    
} // END OF PREVIEW

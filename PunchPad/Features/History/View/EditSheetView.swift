//
//  EditSheetView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/18/23.
//

import SwiftUI
import ThemeKit

struct EditSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditSheetViewModel
    @State private var isShowingOverrideControls: Bool = false
    private typealias Identifier = ScreenIdentifier.EditSheetView
    private let dateComponentFormatter = FormatterFactory.makeHourAndMinuteDateComponentFormatter()
    private let editControlsId = "editControls"
    private let chevronUpIconName = "chevron.up"
    private let chevronDownIconName = "chevron.down"
    private let currencyCode = "PLN"
    
    init(viewModel: EditSheetViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

//MARK: - Body
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
        }
    }
}

//MARK: - Time Indicator, Labels
private extension EditSheetView {
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
            firstTimerLabel: Strings.timeIndicatorText,
            secondProgress: viewModel.overTimeFraction,
            secondTimerLabel: Strings.overtimeText,
            useOnlyWorkLabel: true)
        .frame(width: 250, height: 250)
    }
    
    var overtimeLabel: some View {
            VStack {
                Text(generateTimeIntervalLabel(value: viewModel.overTimeInSeconds))
                    .font(.title)
                    .accessibilityIdentifier(Identifier.Label.overtimeValue)
                Text(Strings.overtimeText)
                    .font(.caption)
            }
            .foregroundColor(.theme.black)
    }
    
    var regularTimeLabel: some View {
            VStack {
                Text(generateTimeIntervalLabel(value: viewModel.workTimeInSeconds))
                    .font(.title)
                    .accessibilityIdentifier(Identifier.Label.worktimeValue)
                Text(Strings.regularTimeText)
                    .font(.caption)
            }
            .foregroundColor(.theme.black)
    }
    
    var breakTimeLabel: some View {
        VStack {
            Text(generateTimeIntervalLabel(value: viewModel.breakTime))
                .font(.title)
                .accessibilityIdentifier(Identifier.Label.breaktimeValue)
            Text(Strings.breaktimeText)
                .font(.caption)
        }
        .foregroundColor(.theme.black)
    }
    
    func generateTimeIntervalLabel(value: TimeInterval) -> String {
        return dateComponentFormatter.string(from: value) ?? "00:00"
    }
}

//MARK: - Date Controls
private extension EditSheetView {
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
            CustomDatePickerContainer(labelText: Strings.startDateText) {
                DatePicker(Strings.startDateText, selection: $viewModel.startDate, in: PartialRangeThrough(viewModel.finishDate))
                    .labelsHidden()
                    .accessibilityIdentifier(Identifier.DatePicker.startDate)
            } trailing: {
               calendarToggable
            }
            .frame(height: 50)
            .padding(.top)
            .padding(.bottom, 2)
            
            CustomDatePickerContainer(labelText: Strings.finishDateText) {
                DatePicker(Strings.finishDateText, selection: $viewModel.finishDate, in: PartialRangeFrom(viewModel.startDate))
                    .labelsHidden()
                    .accessibilityIdentifier(Identifier.DatePicker.finishDate)
            } trailing: {
                calendarToggable
            }
            .frame(height: 50)
            .padding(.bottom)
        }
        
    }
    
    var sameDayDateControls: some View {
        Group {
            CustomDatePickerContainer(labelText: Strings.dateText) {
                DatePicker(selection: $viewModel.startDate,
                           displayedComponents: .date) {
                    EmptyView()
                }
                           .labelsHidden()
                           .accessibilityIdentifier(Identifier.DatePicker.date)
            } trailing: {
                calendarToggable
            }
            .frame(height: 50)
            .padding(.top)
            .padding(.bottom, 2)
            HStack {
                CustomDatePickerContainer(labelText: Strings.startDateText) {
                    DatePicker(selection: $viewModel.startDate,
                               in: PartialRangeThrough(viewModel.finishDate),
                               displayedComponents: .hourAndMinute) {
                        EmptyView()
                    }
                               .labelsHidden()
                               .accessibilityIdentifier(Identifier.DatePicker.startTime)
                } trailing: {
                    imageClock
                }
                .frame(height: 50)
                CustomDatePickerContainer(labelText: Strings.finishDateText) {
                    DatePicker(selection: $viewModel.finishDate,
                               in: PartialRangeFrom(viewModel.startDate),
                               displayedComponents: .hourAndMinute) {
                        EmptyView()
                    }
                               .labelsHidden()
                               .accessibilityIdentifier(Identifier.DatePicker.finishTime)
                } trailing: {
                    imageClock
                }
                .frame(height: 50)
            }
            .padding(.bottom)
        }
    }
}

//MARK: - Override Settings Controls
private extension EditSheetView {
    @ViewBuilder
    func overrideControls(_ proxy: ScrollViewProxy) -> some View {
        overrideSettingsHeader(proxy)
        if isShowingOverrideControls {
            overrideContent
        }
         
    }
    
    @ViewBuilder 
    func overrideSettingsHeader(_ proxy: ScrollViewProxy) -> some View {
        HStack {
            Image(systemName: isShowingOverrideControls ? chevronUpIconName : chevronDownIconName)
                .foregroundColor(.theme.primary)
                .fontWeight(.bold)
                .onTapGesture {
                    Task {
                        let duration: TimeInterval = 0.1
                        await animate(duration: duration, animation: .spring(duration: duration)) {
                            isShowingOverrideControls.toggle()
                        }
                        
                        await animate(duration: duration, animation: .spring(duration: duration)) {
                            proxy.scrollTo(editControlsId, anchor: .top)
                        }
                    }
                }
            Text(Strings.overrideSettingsHeaderText)
                .font(.system(size: 24))
            Spacer()
        }
        .frame(height: 50)
    }
    
    var overrideContent: some View {
        Grid(alignment: .leading) {
            divider
            GridRow {
                Text(Strings.maximumOvertimeText)
                TimeIntervalPicker(buttonLabelText: generateTimeIntervalLabel(value: viewModel.currentMaximumOvertime),
                                   value: $viewModel.currentMaximumOvertime
                )
            }
            divider
            GridRow {
                Text(Strings.standardWorkTimeText)
                TimeIntervalPicker(buttonLabelText: generateTimeIntervalLabel(value: viewModel.currentStandardWorkTime),
                                   value: $viewModel.currentStandardWorkTime
                )
            }
            divider
            GridRow {
                Text(Strings.grossPayPerMonthText)
                TextField(currencyCode,
                          value: $viewModel.grossPayPerMonth,
                          format: .currency(code: currencyCode))
                .textFieldStyle(.roundedBorder)
                .foregroundColor(.black)
            }
            divider
            Toggle(isOn: $viewModel.calculateNetPay) {
                Text(Strings.calculateNetPayText)
             
            }
            .tint(.theme.primary)
            .padding(.trailing)
            divider
        }
        .foregroundStyle(Color.theme.blackLabel)
    }
}

//MARK: - Save Controls
extension EditSheetView {
    var editControls: some View {
        Group {
            HStack {
                Button(Strings.cancelButtonText.uppercased()) {
                    dismiss()
                }
                .buttonStyle(CancelButtonStyle())
                .accessibilityIdentifier(Identifier.Button.cancel)
                
                Button(Strings.saveButtonText.uppercased()) {
                    viewModel.saveEntry()
                    dismiss()
                }
                .buttonStyle(ConfirmButtonStyle())
                .accessibilityIdentifier(Identifier.Button.save)
            }
            .id(editControlsId)
        }
    }
}

//MARK: - View Components
extension EditSheetView {
    var title: some View {
        HStack {
            Text(Strings.titleText)
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

//MARK: - Localization
extension EditSheetView: Localized {
    struct Strings {
        static let regularTimeText = Localization.EditSheetScreen.regularTime
        static let overtimeText = Localization.Common.overtime.capitalized
        static let breaktimeText = Localization.EditSheetScreen.breaktime
        static let titleText = Localization.EditSheetScreen.editEntry
        static let timeIndicatorText = Localization.Common.worktime
        static let overrideSettingsHeaderText = Localization.EditSheetScreen.overrideSettings.capitalized
        static let startDateText = Localization.Common.start.capitalized
        static let finishDateText = Localization.Common.finish.capitalized
        static let dateText = Localization.EditSheetScreen.date
        static let saveButtonText = Localization.Common.save
        static let cancelButtonText = Localization.Common.cancel
        static let maximumOvertimeText = Localization.EditSheetScreen.maximumOvertime
        static let standardWorkTimeText = Localization.EditSheetScreen.standardWorkTime
        static let grossPayPerMonthText = Localization.EditSheetScreen.grossPayPerMonth
        static let calculateNetPayText = Localization.EditSheetScreen.calculateNetPay
    }
}
#Preview("Single date controls") {
    struct ContainerView: View {
        private let container = PreviewContainer()
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
    
}

#Preview("Two date controls") {
    struct ContainerView: View {
        private let container = PreviewContainer()
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
    
}

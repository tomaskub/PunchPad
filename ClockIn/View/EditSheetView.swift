//
//  EditSheetView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/18/23.
//

import SwiftUI

struct EditSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: EditSheetViewModel
    @State private var isShowingOverrideControls: Bool = false
    private typealias Identifier = ScreenIdentifier.EditSheetView
    let regularTimeText: String = "Regular time"
    let overtimeText: String = "Overtime"
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
    //MARK: DATE FORMATTER
    let dateComponentFormatter = FormatterFactory.makeDateComponentFormatter()
    
    
} // END OF STRUCT

//MARK: BODY
extension EditSheetView {
    var body: some View {
        ZStack {
            background
            VStack {
                HStack {
                    title
                    Spacer()
                }
                .padding(.top)
                ScrollView {
                    timeIndicator
                        .padding(.bottom)
                    HStack {
                        regularTimeLabel
                        Spacer()
                        overtimeLabel
                    }
                    Divider()
                    dateControls()
                    Divider()
                    overrideSettingsHeader
                        .padding(.top)
                    if isShowingOverrideControls {
                        overrideControls
                    }
                }
                editControls
                .padding(.top)
            } // END OF VSTACK
            .padding(.horizontal, 32)
        } // END OF ZSTACK
    } // END OF BODY
}

// MARK: VIEW BUILDERS & FUNCTIONS
extension EditSheetView {
    @ViewBuilder
    private func dateControls() -> some View {
        if !viewModel.shouldDisplayFullDates {
            sameDayDateControls
        } else {
            diffDayDateControls
        }
    }
    
    private func generateTimeIntervalLabel(value: TimeInterval) -> String {
        return dateComponentFormatter.string(from: value) ?? "00:00"
    }
}

//MARK: OVERRIDE SETTINGS CONTROLS
extension EditSheetView {
    var overrideControls: some View {
        Grid(alignment: .leading) {
            
            GridRow {
                Text(maximumOvertimeText)
                TimeIntervalPicker(buttonLabelText: generateTimeIntervalLabel(value: viewModel.currentMaximumOvertime),
                                   value: $viewModel.currentMaximumOvertime
                )
            }
            
            GridRow {
                Text(standardWorkTimeText)
                TimeIntervalPicker(buttonLabelText: generateTimeIntervalLabel(value: viewModel.currentStandardWorkTime),
                                   value: $viewModel.currentStandardWorkTime
                )
            }
            
            GridRow {
                Text(grossPayPerMonthText)
                TextField("PLN",
                          value: $viewModel.grossPayPerMonth,
                          format: .currency(code: "PLN"))
                .textFieldStyle(.roundedBorder)
            }
            
            Toggle(isOn: .constant(true)) {
                Text(calculateNetPayText)
            }
            .padding(.trailing)
        }
    }
}

//MARK: DATE CONTROLS
extension EditSheetView {
    var diffDayDateControls: some View {
        Group {
            DatePicker(startDateText, selection: $viewModel.startDate)
                .accessibilityIdentifier(Identifier.DatePicker.startDate.rawValue)
            DatePicker(finishDateText, selection: $viewModel.finishDate)
                .accessibilityIdentifier(Identifier.DatePicker.finishDate.rawValue)
        }
    }
    
    var sameDayDateControls: some View {
        Group {
            DatePicker(selection: $viewModel.startDate,
                       displayedComponents: .date) {
                Image(systemName: "calendar")
            }
                       .fixedSize()
            HStack {
                VStack(alignment: .leading) {
                    Text(startDateText)
                        .font(.caption)
                    
                    DatePicker(selection: $viewModel.startDate,
                               in: PartialRangeThrough(viewModel.finishDate),
                               displayedComponents: .hourAndMinute) {
                        Image(systemName: "clock")
                    }
                               .fixedSize()
                }
                VStack(alignment: .leading) {
                    Text(finishDateText)
                        .font(.caption)
                    DatePicker(selection: $viewModel.finishDate,
                               in: PartialRangeFrom(viewModel.startDate),
                               displayedComponents: .hourAndMinute) {
                        Image(systemName: "clock")
                    }
                               .fixedSize()
                }
            }
        }
    }
}

//MARK: TIME INDICATOR & LABELS
extension EditSheetView {
    var timeIndicator: some View {
        ZStack {
            RingView(startPoint: 0,
                     endPoint: viewModel.workTimeFraction,
                     ringColor: .blue,
                     ringWidth: 5,
                     displayPointer: false
            )
            RingView(startPoint: 0,
                     endPoint: viewModel.overTimeFraction,
                     ringColor: .green,
                     ringWidth: 5,
                     displayPointer: false
            )
                .padding(10)
            VStack {
                Text(timeIndicatorText.uppercased())
                    .font(.caption)
                Text(generateTimeIntervalLabel(value: viewModel.totalTimeInSeconds))
                    .font(.largeTitle)
            }
        }  // END OF ZSTACK
        .frame(width: 250, height: 250)
    }
    
    var overtimeLabel: some View {
            HStack {
                Text(generateTimeIntervalLabel(value: viewModel.overTimeInSeconds))
                    .font(.title)
                Text(overtimeText)
                    .font(.caption)
            }
    }
    
    var regularTimeLabel: some View {
            HStack {
                Text(generateTimeIntervalLabel(value: viewModel.workTimeInSeconds))
                    .font(.title)
                Text(regularTimeText)
                    .font(.caption)
            }
    }
}

//MARK: STATIC VIEW VAR
extension EditSheetView {
    var title: some View {
        Text(titleText)
            .font(.title)
    }
    
    var overrideSettingsHeader: some View {
        HStack {
            Image(systemName: "chevron.down")
                .onTapGesture {
                    isShowingOverrideControls.toggle()
                }
            Text(overrideSettingsHeaderText)
            Spacer()
        }
    }
    
    var background: some View {
        BackgroundFactory.buildSolidColor(.gray.opacity(0.1))
    }
}

//MARK: SAVE CONTROLS
extension EditSheetView {
    var editControls: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text(cancelButtonText.uppercased())
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 140, height: 38)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.gray)
                    } // END OF BACKGROUND
            } // END OF BUTTON
            .accessibilityIdentifier(Identifier.Button.cancel.rawValue)
            Button {
                viewModel.saveEntry()
                dismiss()
            } label: {
                Text(saveButtonText.uppercased())
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 140, height: 38)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue)
                    } // END OF BACKGROUND
            } // END OF BUTTON
            .accessibilityIdentifier(Identifier.Button.save.rawValue)
        } // END OF HSTACK
    }
}

struct EditSheetView_Previews: PreviewProvider {
    private struct ContainerView: View {
        
        @StateObject private var container: Container = .init()
        private let entry: Entry = {
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let startDate = Calendar.current.date(byAdding: .hour, value: 6, to: startOfDay)!
            let finishDate = Calendar.current.date(byAdding: .minute,
                                                   value: 9 * 60 + 30,
                                                   to: startDate)!
            return Entry(startDate: startDate,
                         finishDate: finishDate,
                         workTimeInSec: 8*3600,
                         overTimeInSec: 3600 + 1800,
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
    static var previews: some View {
        ContainerView()
    } // END OF PREVIEWS
} // END OF PREVIEW

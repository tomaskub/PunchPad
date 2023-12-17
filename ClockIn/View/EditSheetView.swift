//
//  EditSheetView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/18/23.
//

import SwiftUI

struct EditSheetView: View {
    
    private typealias Identifier = ScreenIdentifier.EditSheetView
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: EditSheetViewModel
    @State private var isShowingOverrideControls: Bool = false
    let regularTimeText: String = "Regular time"
    let overtimeText: String = "Overtime"
    let titleText: String = "Edit entry"
    let timeIndicatorText: String = "work time"
    let overrideSettingsHeaderText: String = "Override settings"
    let startDateText: String = "Start date"
    let finishDateText: String = "Finish date"
    let saveButtonText: String = "save"
    let cancelButtonText: String = "cancel"
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
                    dateControls
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
    
    var overrideControls: some View {
    //TODO: REPLACE PLACEHOLDERS WITH REAL VALUES
        Grid(alignment: .leading) {
            // row for overtime allowed in seconds
            GridRow {
                Text("Maximum overtime")
                TextField("Hours",
                          text: .constant("5 hours"))
                .textFieldStyle(.roundedBorder)
            }
            // row for standard worktime
            GridRow {
                Text("Standard work time")
                TextField("Hours",
                          text: .constant("8 hours"))
                .textFieldStyle(.roundedBorder)
            }
            // row for gross pay per mont
            GridRow {
                Text("Gross pay per month")
                TextField("PLN",
                          text: .constant("10900"))
                .textFieldStyle(.roundedBorder)
            }
            // row for calculated net pay
            Toggle(isOn: .constant(true)) {
                Text("Calculate net pay")
            }
            .padding(.trailing)
        }
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
    
    var overtimeLabel: some View {
            HStack {
                Text(String(viewModel.overTimerString))
                    .font(.title)
                Text(overtimeText)
                    .font(.caption)
            }
    }
    
    var regularTimeLabel: some View {
            HStack {
                Text(String(viewModel.workTimeString))
                    .font(.title)
                Text(regularTimeText)
                    .font(.caption)
            }
    }
    
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
    
    var dateControls: some View {
        Group {
            DatePicker(startDateText, selection: $viewModel.startDate)
                .accessibilityIdentifier(Identifier.DatePicker.startDate.rawValue)
            DatePicker(finishDateText, selection: $viewModel.finishDate)
                .accessibilityIdentifier(Identifier.DatePicker.finishDate.rawValue)
        }
    }
    
    var timeIndicator: some View {
        ZStack {
            RingView(startPoint: .constant(0),endPoint: $viewModel.workTimeFraction, ringColor: .blue, ringWidth: 5,displayPointer: false)
            RingView(startPoint: .constant(0), endPoint: $viewModel.overTimeFraction, ringColor: .green, ringWidth: 5, displayPointer: false)
                .padding(10)
            VStack {
                Text(timeIndicatorText.uppercased())
                    .font(.caption)
                Text("04:20")
                    .font(.largeTitle)
            }
        }  // END OF ZSTACK
        .frame(width: 250, height: 250)
    }
    
    var title: some View {
        Text(titleText)
            .font(.title)
    }
    
    var background: some View {
        BackgroundFactory.buildSolidColor(.gray.opacity(0.1))
    }
} // END OF STRUCT

struct EditSheetView_Previews: PreviewProvider {
    private struct ContainerView: View {
        
        @StateObject private var container: Container = .init()
        private let entry: Entry = {
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let startDate = Calendar.current.date(byAdding: .hour, value: 6, to: startOfDay)!
            let finishDate = Calendar.current.date(byAdding: .hour, value: 9, to: startDate)!
            return Entry(startDate: startDate, 
                         finishDate: finishDate,
                         workTimeInSec: 8*3600,
                         overTimeInSec: 3600,
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
                                                   entry: entry)
                )
            }
        }
    }
    static var previews: some View {
        ContainerView()
    } // END OF PREVIEWS
} // END OF STRUCT

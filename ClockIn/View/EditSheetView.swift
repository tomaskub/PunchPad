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
    @State private var isShowingOverrideControls: Bool = true//false
    let regularTimeText: String = "Regular time"
    let overtimeText: String = "Overtime"
    var body: some View {
        ZStack {
            background
            //TODO: REPLACE WITH SCROLLING VIEW
            VStack {
                title
                timeIndicator
                .padding(.bottom)
                regularTimeLabel
                overtimeLabel
                    .padding(.bottom)
                dateControls
                overrideSettingsHeader
                    .padding(.top)
                if isShowingOverrideControls {
                    Rectangle()
                        .foregroundColor(.accentColor)
                        .frame(height: 250)
                        .overlay {
                            Text("Override placeholder")
                        }
                }
                editControls
                .padding(.top)
            } // END OF VSTACK
            .padding(.horizontal, 32)
        } // END OF ZSTACK
    } // END OF BODY
    var overrideSettingsHeader: some View {
        HStack {
            Text("Override settings")
            Spacer()
            Image(systemName: "chevron.down")
                .onTapGesture {
                    isShowingOverrideControls.toggle()
                }
        }
    }
    var overtimeLabel: some View {
        HStack {
            Text(overtimeText)
            Spacer()
            Text(viewModel.overTimerString)
                .accessibilityIdentifier(Identifier.Label.overtimeValue.rawValue)
//                .padding(EdgeInsets(top: 4, leading: 28, bottom: 4, trailing: 28))
//                .background {
//                    Rectangle()
//                        .cornerRadius(8)
//                    .opacity(0.05)
//                } // END OF BACKGROUND
        } // END OF HSTACK
    }
    var regularTimeLabel: some View {
        HStack {
            Text(regularTimeText)
            Spacer()
            Text(viewModel.workTimeString)
                .accessibilityIdentifier(Identifier.Label.timeWorkedValue.rawValue)
//                .padding(EdgeInsets(top: 4, leading: 28, bottom: 4, trailing: 28))
//                .background {
//                    Rectangle()
//                        .cornerRadius(8)
//                    .opacity(0.05)
//                } // END OF BACKGROUND
        } // END OF HSTACK
    }
    var editControls: some View {
        HStack {
            Button {
                viewModel.saveEntry()
                dismiss()
            } label: {
                Text("SAVE")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 140, height: 38)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue)
                    } // END OF BACKGROUND
            } // END OF BUTTON
            .accessibilityIdentifier(Identifier.Button.save.rawValue)
            Button {
                dismiss()
            } label: {
                Text("CANCEL")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 140, height: 38)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.gray)
                    } // END OF BACKGROUND
            } // END OF BUTTON
            .accessibilityIdentifier(Identifier.Button.cancel.rawValue)
        } // END OF HSTACK
    }
    var dateControls: some View {
        Group {
            DatePicker("Start date", selection: $viewModel.startDate)
                .accessibilityIdentifier(Identifier.DatePicker.startDate.rawValue)
            DatePicker("Finish date:", selection: $viewModel.finishDate)
                .accessibilityIdentifier(Identifier.DatePicker.finishDate.rawValue)
        }
    }
    var timeIndicator: some View {
        ZStack {
            RingView(startPoint: .constant(0),endPoint: $viewModel.workTimeFraction, ringColor: .blue, ringWidth: 5,displayPointer: false)
            RingView(startPoint: .constant(0), endPoint: $viewModel.overTimeFraction, ringColor: .green, ringWidth: 5, displayPointer: false)
                .padding(10)
        }  // END OF ZSTACK
        .frame(width: 250, height: 250)
    }
    var title: some View {
        Text("Edit Entry")
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

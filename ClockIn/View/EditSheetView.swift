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
    
    var body: some View {
        ZStack {
            GradientFactory.build(colorScheme: colorScheme)
            VStack{
                ZStack {
                    RingView(progress: $viewModel.workTimeFraction, ringColor: .blue, displayPointer: false)
                    RingView(progress: $viewModel.overTimeFraction, ringColor: .green, displayPointer: false)
                        .padding(30)
                }  // END OF ZSTACK
                .frame(width: 250, height: 250)
                .padding(.bottom)
                DatePicker("Start date", selection: $viewModel.startDate)
                    .accessibilityIdentifier(Identifier.DatePicker.startDate.rawValue)
                DatePicker("Finish date:", selection: $viewModel.finishDate)
                    .accessibilityIdentifier(Identifier.DatePicker.finishDate.rawValue)
                Divider()
                HStack {
                    Text("Time worked:")
                    Spacer()
                    Text(viewModel.workTimeString)
                        .accessibilityIdentifier(Identifier.Label.timeWorkedValue.rawValue)
                        .padding(EdgeInsets(top: 4, leading: 28, bottom: 4, trailing: 28))
                        .background {
                            Rectangle()
                                .cornerRadius(8)
                            .opacity(0.05)
                        } // END OF BACKGROUND
                } // END OF HSTACK
                .padding(.top)
                HStack {
                    Text("Overtime:")
                    Spacer()
                    Text(viewModel.overTimerString)
                        .accessibilityIdentifier(Identifier.Label.overtimeValue.rawValue)
                        .padding(EdgeInsets(top: 4, leading: 28, bottom: 4, trailing: 28))
                        .background {
                            Rectangle()
                                .cornerRadius(8)
                            .opacity(0.05)
                        } // END OF BACKGROUND
                } // END OF HSTACK
                .padding(.top)
                Divider()
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
                .padding(.top)
            } // END OF VSTACK
            .padding(.horizontal)
        } // END OF ZSTACK
    } // END OF BODY
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
                         overTimeInSec: 1*3600)
        }()
        var body: some View {
            EditSheetView(viewModel:
                            EditSheetViewModel(dataManager: container.dataManager,
                                               entry: entry)
            )
        }
    }
    static var previews: some View {
        ContainerView()
    } // END OF PREVIEWS
} // END OF STRUCT

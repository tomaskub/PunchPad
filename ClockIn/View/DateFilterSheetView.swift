//
//  DateFilterSheet.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 11/12/2023.
//

import SwiftUI

struct DateFilterSheetView: View {
    let title: String = "Filter"
    let toLabel: String = "To:"
    let fromLabel: String = "From:"
    let sortLabel: String = "Oldest entries first"
    @Environment(\.dismiss) var dismiss
    @Binding var fromDate: Date
    @Binding var toDate: Date
    @Binding var sortAscending: Bool
    let cancelAction: () -> Void
    let confirmAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .fontWeight(.semibold)
            DatePicker(fromLabel, 
                       selection: $fromDate,
                       displayedComponents: .date)
            DatePicker(toLabel, 
                       selection: $toDate,
                       displayedComponents: .date)
            Toggle(sortLabel, isOn: $sortAscending)
                .padding(.vertical)
            buttonPanel
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 32)
    }
    
    var buttonPanel: some View {
        HStack {
            Button(role: .cancel) {
                cancelAction()
                dismiss()
            } label: {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Button {
                confirmAction()
                dismiss()
            } label: {
                Text("Apply")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    Color.gray.ignoresSafeArea()
        .popover(isPresented: .constant(true)) {
            DateFilterSheetView(fromDate: .constant(Date()),
                                toDate: .constant(Date()),
                                sortAscending: .constant(true)
            ) {
               print("Cancel pressed")
            } confirmAction: {
                print("Confirm pressed")
            }
            
            .presentationDetents([.fraction(0.4)])
        }
}

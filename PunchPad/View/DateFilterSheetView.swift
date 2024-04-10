//
//  DateFilterSheet.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 11/12/2023.
//

import SwiftUI

struct DateFilterSheetView: View {
    private let title: String = "Filter"
    private let toLabel: String = "To:"
    private let fromLabel: String = "From:"
    private let sortLabel: String = "Oldest entries first"
    @Environment(\.dismiss) private var dismiss
    @Binding var fromDate: Date
    @Binding var toDate: Date
    @Binding var sortAscending: Bool
    private let cancelAction: () -> Void
    private let confirmAction: () -> Void
    
    init(fromDate: Binding<Date>, toDate: Binding<Date>, sortAscending: Binding<Bool>, cancelAction: @escaping () -> Void, confirmAction: @escaping () -> Void) {
        self._fromDate = fromDate
        self._toDate = toDate
        self._sortAscending = sortAscending
        self.cancelAction = cancelAction
        self.confirmAction = confirmAction
    }
    
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
                .tint(.theme.primary)
                .padding(.vertical)
            buttonPanel
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 32)
    }
    
    private var buttonPanel: some View {
        HStack {
            Button(role: .cancel) {
                cancelAction()
                dismiss()
            } label: {
                Text("Cancel")
                    
            }
            .buttonStyle(CancelButtonStyle())
            
            Button {
                confirmAction()
                dismiss()
            } label: {
                Text("Apply")
            }
            .buttonStyle(ConfirmButtonStyle())
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

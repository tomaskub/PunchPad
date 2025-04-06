//
//  ConfirmDeleteRowView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 04/01/2024.
//

import DomainModels
import SwiftUI

public struct ConfirmDeleteRowView: View {
    private typealias Identifier = ScreenIdentifier.HistoryView.ConfirmDeleteDialogView
    let iconSystemName: String
    let headingText: String
    let confirmAction: () -> Void
    let cancelAction: () -> Void

    public init(
        _ headingText: String,
        iconSystemName: String,
        confirmAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) {
        self.iconSystemName = iconSystemName
        self.headingText = headingText
        self.confirmAction = confirmAction
        self.cancelAction = cancelAction
    }
    public var body: some View {
        VStack {
            Label(
                title: {
                    Text(headingText)
                        .foregroundColor(.theme.blackLabel)
                        .font(.system(size: 14))
                        .accessibilityIdentifier(Identifier.dialogLabel)
                },
                icon: { Image(systemName: iconSystemName)
                        .foregroundColor(.theme.redLabel)
                }
            )
            
            HStack {
                Button("Cancel") {
                 cancelAction()
                }
                .buttonStyle(.dismissive)
                .accessibilityIdentifier(Identifier.cancelButton)
                
                Button("Ok") {
                    confirmAction()
                }
                .buttonStyle(.confirming)
                .accessibilityIdentifier(Identifier.okButton)
            }
        }
    }
}

#Preview("ConfirmDeleteRowView") {
    List {
        ConfirmDeleteRowView("Are you sure you want to delete this item?",
                             iconSystemName: "checkmark.circle") { } cancelAction: { }
    }
    .listStyle(.insetGrouped)
    .scrollContentBackground(.hidden)
    .background {
        BackgroundFactory.buildSolidColor()
    }
}

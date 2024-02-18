//
//  NotificationModalView.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 17/02/2024.
//

import SwiftUI
import ThemeKit

struct NotificationModalView<Content: View>: View {
    @Binding var isPresented: Bool
    let cancelText: String
    let confirmText: String
    let cancelAction: () -> Void
    let confirmAction: () -> Void
    let notificationText: () -> Content
    
    var body: some View {
        VStack {
            notificationText()
                
            HStack {
                Button(cancelText) {
                    cancelAction()
                    isPresented.toggle()
                }
                .buttonStyle(.dismissive)
                
                Button(confirmText) {
                    confirmAction()
                    isPresented.toggle()
                }
                .buttonStyle(.confirming)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.theme.white)
        )
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var isPresentingNotificationModalView: Bool = true
        var body: some View {
            ZStack {
                BackgroundFactory.buildSolidColor()
                NotificationModalView(isPresented: $isPresentingNotificationModalView, cancelText: "Cancel", confirmText: "Confirm") {
                    print("Cancel pressed")
                } confirmAction: {
                    print("Confirm pressed")
                } notificationText: {
                    Text("This is notification text for preview, \nThis is notification text for preview with multiline text alignment")
                        .foregroundColor(.theme.blackLabel)
                        .multilineTextAlignment(.leading)
                }
                .padding()

            }
        }
    }
    return PreviewContainer()
}

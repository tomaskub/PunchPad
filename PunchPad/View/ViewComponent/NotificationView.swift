//
//  NotificationView.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 14/02/2024.
//

import SwiftUI
import ThemeKit

struct NotificationView<Icon: View>: View {
    @Binding var isPresented: Bool
    let notificationText: String
    let iconImage: () -> Icon
    var body: some View {
        HStack {
            iconImage()
            
            Text(notificationText)
                .foregroundColor(.theme.blackLabel)
                .frame(maxWidth: .infinity,
                       alignment: .leading
                )
            
            Image(systemName: "xmark")
                .foregroundColor(.theme.blackLabel)
                .onTapGesture {
                    withAnimation(.linear(duration: 0.2)) {
                        isPresented.toggle()
                    }
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.theme.white)
                .shadow(color: .theme.black.opacity(0.2), radius: 6, x: 0, y: 0)
        )
        .opacity(isPresented ? 1 : 0)
    }
}

#Preview {
    struct PreviewContainer: View {
        @State var isPresentingNotification: Bool = true
        var body: some View {
            ZStack {
                BackgroundFactory.buildSolidColor()
                NotificationView(isPresented: $isPresentingNotification,
                                 notificationText: "Sample notification text") {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 32)
            }
        }
    }
    return PreviewContainer()
}

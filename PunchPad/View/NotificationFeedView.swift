//
//  NotificationFeedView.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 17/02/2024.
//

import SwiftUI
import ThemeKit
import Combine

struct InAppNotification: Identifiable, Hashable {
    let id: UUID
    let notificationText: String
    init(id: UUID = UUID(), _ notificationText: String) {
        self.id = id
        self.notificationText = notificationText
    }
}

struct NotificationFeedView: View {
    var notifications: [InAppNotification] = [
    InAppNotification("notification text 1"),
    InAppNotification("notification text 2"),
    InAppNotification("notification text 3"),
    InAppNotification("latest notification")]
    var last3Notifications: [InAppNotification] {
        Array(notifications.suffix(3))
    }
    @State private var notificationIsPresented: [Bool] = Array(repeating: true, count: 3)
    var body: some View {
        VStack {
            ForEach(last3Notifications) { notification in
                NotificationView(isPresented: bindingForPresentingNotification(notification),
                                 notificationText: notification.notificationText) {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.theme.primary)
                }
            }
        }
    }
    
    func bindingForPresentingNotification(_ notification: InAppNotification) -> Binding<Bool> {
        return Binding {
            // get
            if last3Notifications.contains(where: { last3 in
                last3.id == notification.id
            }) {
                return true
            } else {
                return false
            }
        } set: { value in
            if value == false {
                notifications.removeAll { existingNotification in
                    existingNotification.id == notification.id
                }
            }
        }

//        return .constant(true)
    }
}

#Preview {
    struct PreviewContainer: View {
        var body: some View {
            ZStack {
                BackgroundFactory.buildSolidColor()
                NotificationFeedView()
                    .padding(.horizontal)
            }
        }
    }
    return PreviewContainer()
}

//
//  OnboardingNotificationView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 06/11/2023.
//

import SwiftUI
import ThemeKit

struct OnboardingNotificationView: View {
    private typealias Identifier = ScreenIdentifier.OnboardingView
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 40) { 
            TextFactory.buildTitle(Strings.titleText)
            
            TextFactory.buildDescription(Strings.descriptionText)
            
            Toggle(Strings.toggleText, isOn: $viewModel.settingsStore.isSendingNotification)
                .foregroundColor(.theme.blackLabel)
                .tint(.theme.primary)
                .accessibilityIdentifier(Identifier.Toggles.notifications.rawValue)
                .padding()
                .background()
                .cornerRadius(20)
        }
        .padding(30)
        .alert(Strings.alertTitle,
               isPresented: $viewModel.shouldShowNotificationDeniedAlert) {
            Button(Strings.alertButtonText) {
                viewModel.shouldShowNotificationDeniedAlert = false
            }
        } message: {
            Text(Strings.alertMessage)
        }
    }
}

//MARK: - Localization
extension OnboardingNotificationView: Localized {
    struct Strings {
        static let titleText = Localization.OnboardingNotificationScreen.notifications
        static let descriptionText = Localization.OnboardingNotificationScreen.descriptionText
        static let toggleText = Localization.OnboardingNotificationScreen.sendNotificationsOnFinish
        static let alertTitle = Localization.OnboardingNotificationScreen.needsPermission
        static let alertMessage = Localization.OnboardingNotificationScreen.allowForNotifications
        static let alertButtonText = Localization.Common.ok.uppercased()
    }
}

struct OnboardingNotification_Preview: PreviewProvider {
    private struct PreviewContainerView: View {
        @StateObject private var vm: OnboardingViewModel
        private let container: PreviewContainer
        @Environment(\.colorScheme) private var colorScheme
        
        init() {
            let container = PreviewContainer()
            self.container = container
            self._vm = StateObject(wrappedValue: 
                                    OnboardingViewModel(
                                        notificationService: container.notificationService,
                                        settingsStore: container.settingsStore)
            )
        }
        
        var body: some View {
            ZStack {
                BackgroundFactory.buildSolidColor()
                OnboardingNotificationView(viewModel: vm)
                VStack {
                    Spacer()
                    Button( "Preview button") {
                        
                    }
                    .buttonStyle(.confirming)
                        .padding(30)
                }
            }
        }
    }
    static var previews: some View {
        PreviewContainerView()
    }
}

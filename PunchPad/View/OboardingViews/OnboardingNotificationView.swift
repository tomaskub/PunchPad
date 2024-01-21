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
    let titleText: String = "Notifications"
    let descriptionText: String = "Do you want PunchPad to send you notifications when the work time is finished?"
    let alertTitle: String = "PunchPad needs permission to show notifications"
    let alertMessage: String = "You need to allow for notification in settings"
    let alertButtonText: String = "OK"
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 40) {
            TextFactory.buildTitle(titleText)
            
            TextFactory.buildDescription(descriptionText)
            
            Toggle("Send notifications on finish", isOn: $viewModel.settingsStore.isSendingNotification)
                .disabled(viewModel.authorizationDenied)
                .foregroundColor(.theme.blackLabel)
                .tint(.theme.primary)
                .accessibilityIdentifier(Identifier.Toggles.notifications.rawValue)
                .padding()
                .background()
                .cornerRadius(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(
                            viewModel.authorizationDenied ? 
                            Color.white.opacity(0.1) : Color.clear
                        )
                        .onTapGesture {
                            showAlert.toggle()
                        }
                }
        }
        .padding(30)
        .alert(alertTitle,
               isPresented: $showAlert) {
            Button(alertButtonText) {
                showAlert.toggle()
            }
        } message: {
            Text(alertMessage)
        }
    }
}

struct OnboardingNotification_Preview: PreviewProvider {
    private struct PreviewContainerView: View {
        @StateObject private var vm: OnboardingViewModel
        @StateObject private var container: Container
        @Environment(\.colorScheme) private var colorScheme
        
        init() {
            let container = Container()
            self._container = StateObject(wrappedValue: container)
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

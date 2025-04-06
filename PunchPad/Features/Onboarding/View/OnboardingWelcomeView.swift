//
//  OnboardingWelcomeView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 04/11/2023.
//
import DomainModels
import UIComponents
import SwiftUI
import ThemeKit

struct OnboardingWelcomeView: View {
    private let logoResource: String = "LaunchLogo"
    
    var body: some View {
        VStack(spacing: 40) {
            
            Image(logoResource)
                 .resizable()
                 .aspectRatio(contentMode: .fit)
    
            TextFactory.buildDescription(Strings.descriptionText)
                .padding()
            
            Spacer()
        }
        .padding(30)
    }
}
// MARK: - Localization
extension OnboardingWelcomeView: Localized {
    struct Strings {
        static let descriptionText =  Localization.OnboardingWelcomeScreen.description
    }
}

#Preview {
    struct PreviewContainerView: View {
        @Environment(\.colorScheme) private var colorScheme
        var body: some View {
            ZStack {
                BackgroundFactory.buildSolidColor()
                OnboardingWelcomeView()
                VStack {
                    Spacer()
                    Button("Preview button") {
                        // do nothing
                    }
                    .buttonStyle(.confirming)
                }.padding(30)
            }
        }
    }
    return PreviewContainerView()
}

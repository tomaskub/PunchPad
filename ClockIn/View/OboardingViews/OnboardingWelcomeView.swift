//
//  OnboardingWelcomeView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 04/11/2023.
//

import SwiftUI
import ThemeKit

struct OnboardingWelcomeView: View {
    let logoResource: String = "LaunchLogo"
    let descriptionText: String = "This app was built to help you track time and make sure you are spending at work exactly the time you want and need. \n\n Plan your workdays and plan your paycheck!"
    
    var body: some View {
        VStack(spacing: 40){
            
            Image(logoResource)
                 .resizable()
                 .aspectRatio(contentMode: .fit)
            
            TextFactory.buildDescription(descriptionText)
                .padding()
            
            Spacer()
        }
        .padding(30)
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
                        //do nothing
                    }
                    .buttonStyle(.confirming)
                }.padding(30)
            }
        }
    }
    return PreviewContainerView()
}

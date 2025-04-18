//
//  OnboardingFinishView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 06/11/2023.
//

import SwiftUI
import UIComponents

struct OnboardingFinishView: View {
    private let titleText: String = "PunchPad has been succsessfully set up"
    private let descriptionText: String = "You are all ready to go! Enjoy using the app!"
    
    var body: some View {
        VStack(spacing: 40) {
            title
            description
        }
        .padding(30)
    }
    
    var title: some View {
        TextFactory.buildMultilineTitle(titleText)
    }
    var description: some View {
        TextFactory.buildDescription(descriptionText)
    }
}

struct OnboardingFinishPreview: PreviewProvider {
    private struct PreviewContainerView: View {
        @Environment(\.colorScheme) private var colorScheme
        var body: some View {
            ZStack {
                BackgroundFactory.buildSolidColor()
                OnboardingFinishView()
                VStack {
                    Spacer()
                    Button("Preview button") {
                        
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

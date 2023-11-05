//
//  OnboardingWelcomeView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 04/11/2023.
//

import SwiftUI

struct OnboardingWelcomeView: View {
    
    let titleText: String = "ClockIn"
    let descriptionText: String = "This app was built to help you track time and make sure you are spending at work exactly the time you want and need. \n\n Plan your workdays and plan your paycheck!"
    
    var body: some View {
        VStack(spacing: 40){
            
            logoView
            
            title
            
            description
            
            Spacer()
        }
        .padding(30)
    }
    
    var logoView: some View {
        ZStack {
            Circle()
                .trim(from: 0.15, to: 0.85)
                .stroke(lineWidth: 10)
            Rectangle()
                .frame(width: 10, height: 200)
        }
        .padding(.horizontal)
    }
    
    var title: some View {
        TextFactory.buildTitle(titleText)
    }
    
    var description: some View {
        TextFactory.buildDescription(descriptionText)
    }
}

struct OnboardingWelcome_Previews: PreviewProvider {
    private struct PreviewContainerView: View {
        @Environment(\.colorScheme) private var colorScheme
        var body: some View {
            ZStack {
                GradientFactory.build(colorScheme: colorScheme)
                OnboardingWelcomeView()
                VStack {
                    Spacer()
                    ButtonFactory.build(labelText: "Preview button")
                }.padding(30)
            }
        }
    }
    
    static var previews: some View {
        PreviewContainerView()
    }
}

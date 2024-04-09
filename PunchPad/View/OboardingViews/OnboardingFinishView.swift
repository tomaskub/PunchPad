//
//  OnboardingFinishView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 06/11/2023.
//

import SwiftUI

struct OnboardingFinishView: View {
    private let titleText: String = "PunchPad has been succsessfully set up"
    private let descriptionText: String = "You are all ready to go! Enjoy using the app!"
    
    var body: some View {
        VStack(spacing: 40) {
            title
            description
            //This section is still in works until in-app tutorial is developed
            /*
             Text("To enter a short tutorial on how to use the app and its functions click the tour button. Alternatively, if you are a person that assembles the IKEA furniture without looking at the instructions click the finish button")
             .multilineTextAlignment(.center)
             
             
             Text("Finish!")
             .font(.headline)
             .foregroundColor(.accentColor)
             .frame(height: 55)
             .frame(maxWidth: .infinity)
             .background(Color.primary.colorInvert())
             .cornerRadius(10)
             .overlay {
             HStack {
             Spacer()
             Image(systemName: "bicycle")
             Image(systemName: "figure.walk")
             }
             .padding()
             }
             .onTapGesture {
             dismiss()
             }
             */
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

struct OnboardingFinish_Preview: PreviewProvider {
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

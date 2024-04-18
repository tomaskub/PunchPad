//
//  CircularButton.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 26/12/2023.
//

import SwiftUI

struct CircleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.theme.white)
            .background(
                    Circle()
                        .foregroundColor(.theme.buttonColor)
            )
            .overlay {
                Circle()
                    .stroke(lineWidth: 8)
                    .padding(4)
                    .foregroundColor(.theme.white)
            }
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 4)
    }
    
}

#Preview {
    ZStack{
        BackgroundFactory.buildSolidColor()
        HStack {
            Button { } label: {
                Image(systemName: "play.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .offset(x: 5, y: 0)
                    .frame(width: 100, height: 100)
            }
            .buttonStyle(CircleButton())
            Button { } label: {
                Image(systemName: "pause.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .frame(width: 60, height: 60)
            }
            .buttonStyle(CircleButton())
        }
    }
}

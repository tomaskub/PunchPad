//
//  TimerIndicator.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 26/12/2023.
//

import SwiftUI

struct TimerIndicator: View {
    let firstProgressLabel: String = "worktime".uppercased()
    let secondProgressLabel: String = "overtime".uppercased()
    let timerLabel: String
    let firstProgress: CGFloat
    let secondProgress: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.theme.white)
            Circle()
                .stroke(lineWidth: 20)
                .padding(10)
                .foregroundColor(.theme.ringWhite)
            VStack {
                if secondProgress == 0 {
                    Text(firstProgressLabel)
                        .foregroundColor(.theme.secondaryLabel)
                } else {
                    Text(secondProgressLabel)
                        .foregroundColor(.theme.redLabel)
                }
                Text(timerLabel)
                    .font(.largeTitle)
                    .foregroundColor(.theme.black)
            }
            RingView(startPoint: 0,
                     endPoint: firstProgress,
                     ringColor: .theme.ringGreen,
                     ringWidth: 20,
                     displayPointer: false
            )
            if secondProgress > 0 {
                RingView(startPoint: 0,
                         endPoint: secondProgress,
                         ringColor: .theme.redLabel,
                         ringWidth: 20,
                         displayPointer: false
                )
            }
        }
    }
}

#Preview("State 1 - some time passed") {
    ZStack {
        BackgroundFactory.buildSolidColor()
        TimerIndicator(
            timerLabel: "04:20",
            firstProgress: 260/480,
            secondProgress: 0)
        .frame(width: 260, height: 260)
    }
}

#Preview("State 2 - full worktime") {
        ZStack {
            BackgroundFactory.buildSolidColor()
            TimerIndicator(
                timerLabel: "08:00",
                firstProgress: 1,
                secondProgress: 0)
            .frame(width: 260, height: 260)
        }
}

#Preview("State 3 - overtime") {
    ZStack {
        BackgroundFactory.buildSolidColor()
        TimerIndicator(
            timerLabel: "01:40",
            firstProgress: 1,
            secondProgress: 0.3)
        .frame(width: 260, height: 260)
    }
}

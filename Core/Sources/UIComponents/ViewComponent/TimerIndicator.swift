//
//  TimerIndicator.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 26/12/2023.
//

import SwiftUI

public struct TimerIndicator: View {
    let firstProgressLabel: String
    let secondProgressLabel: String
    let timerLabel: String
    let firstProgress: CGFloat
    let secondProgress: CGFloat
    let useOnlyWorkLabel: Bool
    
    public init(timerLabel: String,
         firstProgress: CGFloat,
         firstTimerLabel: String,
         secondProgress: CGFloat,
         secondTimerLabel: String,
         useOnlyWorkLabel: Bool = false) {
        self.timerLabel = timerLabel
        self.firstProgressLabel = firstTimerLabel
        self.secondProgressLabel = secondTimerLabel
        self.firstProgress = firstProgress
        self.secondProgress = secondProgress
        self.useOnlyWorkLabel = useOnlyWorkLabel
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.theme.white)
            Circle()
                .stroke(lineWidth: 20)
                .padding(10)
                .foregroundColor(.theme.ringWhite)
            VStack {
                if secondProgress == 0 || useOnlyWorkLabel {
                    Text(firstProgressLabel)
                        .font(.system(size: 20))
                        .foregroundColor(.theme.secondaryLabel)
                } else {
                    Text(secondProgressLabel)
                        .font(.system(size: 20))
                        .foregroundColor(.theme.redLabel)
                }
                Text(timerLabel)
                    .font(.system(size: 57))
                    .foregroundColor(.theme.black)
            }
            if firstProgress > 0 {
                RingView(startPoint: 0,
                         endPoint: firstProgress,
                         ringColor: .theme.ringGreen,
                         ringWidth: 20,
                         displayPointer: false
                )
            }
            if secondProgress > 0 {
                RingView(startPoint: 0,
                         endPoint: secondProgress,
                         ringColor: .theme.redLabel,
                         ringWidth: 20,
                         displayPointer: false
                )
            }
        }
        .compositingGroup()
        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.3), radius: 6, x: 0, y: 4)
        
    }
}

#Preview("State 0 - not started") {
    ZStack {
        BackgroundFactory.buildSolidColor()
        TimerIndicator(
            timerLabel: "00:00",
            firstProgress: 0,
            firstTimerLabel: "WORKTIME",
            secondProgress: 0,
            secondTimerLabel: "overtime".capitalized)
        .frame(width: 260, height: 260)
    }
}
#Preview("State 1 - some time passed") {
    ZStack {
        BackgroundFactory.buildSolidColor()
        TimerIndicator(
            timerLabel: "04:20",
            firstProgress: 0.6,
            firstTimerLabel: "WORKTIME",
            secondProgress: 0,
            secondTimerLabel: "overtime".capitalized)
        .frame(width: 260, height: 260)
    }
}

#Preview("State 2 - full worktime") {
        ZStack {
            BackgroundFactory.buildSolidColor()
            TimerIndicator(
                timerLabel: "08:00",
                firstProgress: 1,
                firstTimerLabel: "WORKTIME",
                secondProgress: 0,
                secondTimerLabel: "overtime".capitalized)
            .frame(width: 260, height: 260)
        }
}

#Preview("State 3 - overtime") {
    ZStack {
        BackgroundFactory.buildSolidColor()
        TimerIndicator(
            timerLabel: "01:40",
            firstProgress: 1,
            firstTimerLabel: "WORKTIME",
            secondProgress: 0.3,
            secondTimerLabel: "overtime".capitalized)
        .frame(width: 260, height: 260)
    }
}

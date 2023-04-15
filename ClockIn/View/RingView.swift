//
//  RingView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI

struct RingView: View {
    
    @Binding var progress: CGFloat
    
    var ringColor: Color
    var pointColor: Color?
    var ringWidth: CGFloat = 10
    var startigPoint: CGFloat = 0
    var displayPointer: Bool = true
    var pointerDiameter: CGFloat = 30
    
    var body: some View {
        GeometryReader { proxy in
            
            //Calculate the leading dimension
            let size = min(proxy.size.width, proxy.size.height)
            
            ZStack(alignment: .center) {
                
                //Ring circle
                    Circle()
                        .trim(from: startigPoint, to: progress)
                        .stroke(ringColor, lineWidth: ringWidth)
                        .rotationEffect(.degrees(-90))
                        .opacity(startigPoint <= progress ? 1 : 0)
                        .frame(width: size, height: size)
                    //Ring begining circle
                    Circle()
                        .fill(ringColor)
                        .frame(width: ringWidth)
                        .offset(y: -size/2)
                        .opacity(startigPoint <= progress ? 1: 0)
                        .rotationEffect(.degrees(startigPoint*360))
                
                //Leading point circle
                if displayPointer {
                    Circle()
                        .fill(ringColor)
                        .frame(width: pointerDiameter, height: pointerDiameter)
                        .overlay(content: {
                            Circle()
                                .fill(pointColor ?? ringColor)
                                .padding(5)
                        })
                        .offset(y: -size/2)
                        .rotationEffect(.degrees( progress * 360))
                } else {
                    Circle()
                        .fill(ringColor)
                        .frame(width: ringWidth)
                        .offset(y: -size/2)
                        .rotationEffect(.degrees(progress*360))
                }
            }
        }
        .padding()
    }
}
    

struct RingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RingView(progress: .constant(0.5), ringColor: .black)
                .padding(.horizontal, 50)
        }
    }
}

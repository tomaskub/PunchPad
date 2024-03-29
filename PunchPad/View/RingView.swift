//
//  RingView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI

struct RingView: View {
    var startPoint: CGFloat
    var endPoint: CGFloat
    
    var ringColor: Color
    var pointColor: Color?
    var ringWidth: CGFloat = 10
    var displayPointer: Bool = true
    var pointerDiameter: CGFloat = 30
    
    var body: some View {
        GeometryReader { proxy in
            
            //Calculate the leading dimension
            let size = min(proxy.size.width, proxy.size.height)
            
            ZStack(alignment: .center) {
                
                //Ring circle
                    Circle()
                        .trim(from: startPoint, to: endPoint)
                        .stroke(ringColor, lineWidth: ringWidth)
                        .rotationEffect(.degrees(-90))
                        .opacity(startPoint <= endPoint ? 1 : 0)
                        .frame(width: size, height: size)
                    //Ring begining circle
                    Circle()
                        .fill(ringColor)
                        .frame(width: ringWidth)
                        .offset(y: -size/2)
                        .opacity(startPoint <= endPoint ? 1: 0)
                        .rotationEffect(.degrees(startPoint*360))
                
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
                        .rotationEffect(.degrees( endPoint * 360))
                } else {
                    Circle()
                        .fill(ringColor)
                        .frame(width: ringWidth)
                        .offset(y: -size/2)
                        .rotationEffect(.degrees(endPoint*360))
                }
            }
        }
        .padding(ringWidth/2)
    }
}
    

struct RingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RingView(startPoint: 0, 
                     endPoint: 0.4,
                     ringColor: .black)
                .padding(.horizontal, 50)
        }
    }
}

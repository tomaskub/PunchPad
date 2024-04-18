//
//  RingView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 3/28/23.
//

import SwiftUI

struct RingView: View {
    private var startPoint: CGFloat
    private var endPoint: CGFloat
    private var ringColor: Color
    private var pointColor: Color?
    private var ringWidth: CGFloat
    private var displayPointer: Bool
    private var pointerDiameter: CGFloat
    
    init(startPoint: CGFloat,
         endPoint: CGFloat,
         ringColor: Color,
         pointColor: Color? = nil,
         ringWidth: CGFloat = 10,
         displayPointer: Bool = true,
         pointerDiameter: CGFloat = 30) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.ringColor = ringColor
        self.pointColor = pointColor
        self.ringWidth = ringWidth
        self.displayPointer = displayPointer
        self.pointerDiameter = pointerDiameter
    }
    
    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            
            ZStack(alignment: .center) {
                    Circle()
                        .trim(from: startPoint, to: endPoint)
                        .stroke(ringColor, lineWidth: ringWidth)
                        .rotationEffect(.degrees(-90))
                        .opacity(startPoint <= endPoint ? 1 : 0)
                        .frame(width: size, height: size)
                    Circle()
                        .fill(ringColor)
                        .frame(width: ringWidth)
                        .offset(y: -size/2)
                        .opacity(startPoint <= endPoint ? 1: 0)
                        .rotationEffect(.degrees(startPoint*360))
                
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

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
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                
                //Ring circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(ringColor, lineWidth: ringWidth)
                    .rotationEffect(.degrees(-90))
                    .frame(width: proxy.size.width, height: proxy.size.height)
                //Ring begining circle
                Circle()
                    .fill(ringColor)
                    .frame(width: ringWidth)
                    .offset(y: -proxy.size.width/2)
                //Leading point circle
                Circle()
                    .fill(ringColor)
                    .frame(width: 30)
                    .overlay(content: {
                        Circle()
                            .fill(pointColor ?? ringColor)
                            .padding(5)
                    })
                    .offset(y: -proxy.size.width/2)
                    .rotationEffect(.degrees( progress * 360))
            }
        }
        .padding()
    }
}
    

struct RingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RingView(progress: .constant(0.5), ringColor: .blue)//, pointColor: .black)
//            RingView(ringColor: .blue, pointColor: .black)
        }
    }
}

//
//  OnboardingView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/22/23.
//

import SwiftUI

struct OnboardingView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    //Onboarding stages:
    /*
     0 - welcome and logo
     1 - Set the work time
     2 - Ask if doing overtime and how much
     3 - Send notifications?
     4 - Tour de App
     */
    @State var onboardingStage: Int = 1
    @State var hoursWorking: Int = 8
    @State var minutesWorking: Int = 30
    let tansition: AnyTransition = .asymmetric(
        insertion: .move(edge: .trailing),
        removal: .move(edge: .leading))
    
    var body: some View {
        ZStack{
            //BACKGROUND
            LinearGradient(colors: [ colorScheme == .light ? .white : .black, .blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            //CONTENT
            ZStack {
                switch onboardingStage {
                case 0:
                    stage0Screen
                case 1:
                    stage1Screen
                default:
                    Rectangle()
                        .foregroundColor(.accentColor)
                        .cornerRadius(10)
                        .frame(width: 200, height: 200)
                        .overlay {
                            Text("END OF ON \n BOARDING")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        
                }
            }
            
            VStack {
                Spacer()
                bottomButton
            }
            .padding(30)
        }
    }
}
extension OnboardingView {
    private var stage0Screen: some View {
        VStack(spacing: 40){
            ZStack {
                Circle()
                    .trim(from: 0.15, to: 0.85)
                    .stroke(lineWidth: 10)
                Rectangle()
                    .frame(width: 10, height: 200)
            }
            .padding(.horizontal)
//            Spacer()
            Text("Clock in")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .overlay {
                    Capsule()
                        .frame(height: 3)
                        .offset(y: 20)
                        .foregroundColor(.primary)
                }
            Text("This app was built to help you track time and make sure you are spending at work exactly the time you want and need. \n\n Plan your workdays and plan your paycheck!")
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
//            Spacer()
            Spacer()
        }
        .padding(30)
    }
    
    private var stage1Screen: some View {
        VStack(spacing: 40) {
            Text("Set the work time")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .overlay {
                    Capsule()
                        .frame(height: 3)
                        .offset(y: 20)
                        .foregroundColor(.primary)
                }
            HStack {
                VStack {
                    Text("Hours")
                    Picker("Hours", selection: $hoursWorking) {
                        ForEach(0..<25){ i in
                            Text("\(i)")
                        }
                    }
                    .pickerStyle(.wheel)
                }
                VStack {
                    Text("Minutes")
                    Picker("Minutes", selection: $minutesWorking) {
                        ForEach(0..<60) { i in
                            Text("\(i)")
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
            .padding()
            .padding(.top)
            .background(Color.primary.colorInvert())
            .cornerRadius(20)
        }
        .padding(30)
    }
    
    private var bottomButton: some View {
        Text(onboardingStage == 0 ? "Let's start!" : "Next")
            .font(.headline)
            .foregroundColor(.blue)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(Color.primary.colorInvert())
            .cornerRadius(10)
            .onTapGesture {
                withAnimation(.spring()) {
                    onboardingStage += 1
                }
            }
    }
}
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingView()
            OnboardingView(onboardingStage: 0)
        }
    }
}

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
    @State var onboardingStage: Int = 0
    
    @State var hoursWorking: Int = 8
    @State var minutesWorking: Int = 30
    @State var hoursOvertime: Int = 2
    @State var minutesOvertime: Int = 15
    @State var isOvertimeAllowed: Bool = true //false
    
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
                case 2:
                    stage2Screen
                case 3:
                    stage3Screen
                case 4:
                    stage4Screen
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
                if onboardingStage != 0 {
                    HStack {
                        topButton
                        Spacer()
                    }
                }
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
            
            Spacer()
        }
        .padding(30)
    }
    
    private var stage1Screen: some View {
        VStack(spacing: 40) {
            Text("Workday")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .overlay {
                    Capsule()
                        .frame(height: 3)
                        .offset(y: 20)
                        .foregroundColor(.primary)
                }
            Text("ClockIn needs to know what is your normal workday length to let you know when you are done or when you enter into overtime")
                .multilineTextAlignment(.center)
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
    
    private var stage2Screen: some View {
        VStack(spacing: 40) {
            Text("Overtime")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .overlay {
                    Capsule()
                        .frame(height: 3)
                        .offset(y: 20)
                        .foregroundColor(.primary)
                }
            if !isOvertimeAllowed {
                Text("Let ClockIn know wheter you want to measure overtime")
                    .multilineTextAlignment(.center)
            }
            Toggle("Keep logging overtime", isOn: $isOvertimeAllowed)
                .padding()
                .background()
                .cornerRadius(20)
            if isOvertimeAllowed {
                Text("Let the app know what is the maximum overtime you can work for.")
                    .multilineTextAlignment(.center)
                HStack {
                    VStack {
                        Text("Hours")
                        Picker("Hours", selection: $hoursOvertime) {
                            ForEach(0..<25){ i in
                                Text("\(i)")
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    VStack {
                        Text("Minutes")
                        Picker("Minutes", selection: $minutesOvertime) {
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
        }
        .padding(30)
    }
    
    private var stage3Screen: some View {
        VStack(spacing: 40) {
            Text("Notifications")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .overlay {
                    Capsule()
                        .foregroundColor(.primary)
                        .frame(height: 3)
                        .offset(y: 20)
                }
            Text("Do you want to allow ClockIn to send you notifications when the work time is finished?")
                .multilineTextAlignment(.center)
            
            Toggle("Send notifications on finish", isOn: $isOvertimeAllowed)
                .padding()
                
                .background()
                .cornerRadius(20)
            
        }
        .padding(30)
    }

    private var stage4Screen: some View {
        VStack(spacing: 40) {
            Text("Clock In has been succsessfully set up")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            Text("To enter a short tutorial on how to use the app and its functions click the tour button. Alternatively, if you are a person that assembles the IKEA furniture without looking at the instructions click the finish button")
                .multilineTextAlignment(.center)
            Text("Finish!")
                .font(.headline)
                .foregroundColor(.accentColor)
//            .padding(30)
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
        }
        .padding(30)
    }
    
    private var topButton: some View {
        Text("Back")
            .foregroundColor(.accentColor)
            .onTapGesture {
                withAnimation(.spring()) {
                    onboardingStage -= 1
                }
            }
    }
    
    private var bottomButton: some View {
        Text(onboardingStage == 0 ? "Let's start!" :
                onboardingStage == 4 ? "Take me on tour de app!" : "Next")
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

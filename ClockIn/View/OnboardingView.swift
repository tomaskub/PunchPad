//
//  OnboardingView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/22/23.
//

import SwiftUI

struct OnboardingView: View {
    
    private typealias Identifier = ScreenIdentifier.OnboardingView
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = OnboardingViewModel()
    
    //Onboarding stages:
    /*
     0 - Logo and welcome message
     1 - Set the work time
     2 - Ask if doing overtime and set maximum overtime
     3 - Ask to send notifications on finish
     4 - Ask user for salary and if to calculate net salary (after taxes)
     5 - Inform setup complete, allows to Finish onboarding
     */
    @State var onboardingStage: Int = 0
    
    let tansition: AnyTransition = .asymmetric(
        insertion: .move(edge: .trailing),
        removal: .move(edge: .leading))
    
    var body: some View {
        
        ZStack{
            //BACKGROUND
            GradientFactory.build(colorScheme: colorScheme)
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
                case 5:
                    stage5Screen
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
            
            Text("ClockIn")
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
                    Picker("Hours", selection: $viewModel.hoursWorking) {
                        ForEach(0..<25){ i in
                            Text("\(i)").tag(i)
                        }
                    }
                    .accessibilityIdentifier(Identifier.Pickers.workingHours.rawValue)
                    .pickerStyle(.wheel)
                }
                VStack {
                    Text("Minutes")
                    Picker("Minutes", selection: $viewModel.minutesWorking) {
                        ForEach(0..<60) { i in
                            Text("\(i)").tag(i)
                        }
                    }
                    .accessibilityIdentifier(Identifier.Pickers.workingMinutes.rawValue)
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
            if !viewModel.isLoggingOvertime {
                Text("Let ClockIn know wheter you want to measure overtime")
                    .multilineTextAlignment(.center)
            }
            Toggle("Keep logging overtime", isOn: $viewModel.isLoggingOvertime)
                .accessibilityIdentifier(Identifier.Toggles.overtime.rawValue)
                .padding()
                .background()
                .cornerRadius(20)
            if viewModel.isLoggingOvertime {
                Text("Let the app know what is the maximum overtime you can work for.")
                    .multilineTextAlignment(.center)
                HStack {
                    VStack {
                        Text("Hours")
                        Picker("Hours", selection: $viewModel.hoursOvertime) {
                            ForEach(0..<25){ i in
                                Text("\(i)").tag(i)
                            }
                        }
                        .accessibilityIdentifier(Identifier.Pickers.overtimeHours.rawValue)
                        .pickerStyle(.wheel)
                    }
                    VStack {
                        Text("Minutes")
                        Picker("Minutes", selection: $viewModel.minutesOvertime) {
                            ForEach(0..<60) { i in
                                Text("\(i)").tag(i)
                            }
                        }
                        .accessibilityIdentifier(Identifier.Pickers.overtimeMinutes.rawValue)
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
            
            Toggle("Send notifications on finish", isOn: $viewModel.isSendingNotifications)
                .accessibilityIdentifier(Identifier.Toggles.notifications.rawValue)
                .padding()
                .background()
                .cornerRadius(20)
            
        }
        .padding(30)
    }
    
    private var stage4Screen: some View {
        VStack(spacing: 40) {
            
            Text("Salary")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .overlay(content: {
                    Capsule()
                        .foregroundColor(.primary)
                        .frame(height: 3)
                        .offset(y: 20)
                })
            Text("To let ClockIn calculate the salary you need to enter your gross montly income")
                .multilineTextAlignment(.center)
            HStack {
                Text("Gross paycheck")
                TextField("", text: $viewModel.grossPayPerMonthText)
                    .accessibilityIdentifier(Identifier.TextFields.grossPaycheck.rawValue)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                Text("PLN")
            }
            .padding()
            .background()
            .cornerRadius(20)
            
            Text("Do you want to allow ClockIn to calculate your net salary based on Polish tax law?")
                .multilineTextAlignment(.center)
            Toggle("Calculate net salary", isOn: $viewModel.netPayAvaliable)
                .accessibilityIdentifier(Identifier.Toggles.calculateNetSalary.rawValue)
                .padding()
                .background()
                .cornerRadius(20)
        }
        .padding(30)
    }
    
    private var stage5Screen: some View {
        VStack(spacing: 40) {
            
            Text("Clock In has been succsessfully set up")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("You are all ready to go! Enjoy using the app!")
                .multilineTextAlignment(.center)
            
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
    
    private var topButton: some View {
        Text("Back")
            .accessibilityIdentifier(Identifier.Buttons.regressStage.rawValue)
            .foregroundColor(.accentColor)
            .onTapGesture {
                withAnimation(.spring()) {
                    onboardingStage -= 1
                }
            }
    }
    
    private var bottomButton: some View {
        Text(onboardingStage == 0 ? "Let's start!" :
                onboardingStage == 5 ? "Finish set up!" : "Next")
        .accessibilityIdentifier(Identifier.Buttons.advanceStage.rawValue)
        .font(.headline)
        .foregroundColor(.blue)
        .frame(height: 55)
        .frame(maxWidth: .infinity)
        .background(Color.primary.colorInvert())
        //This section is still in works until in-app tutorial is developed
        /*
         .overlay(content: {
         if onboardingStage == 4 {
         HStack {
         Spacer()
         Image(systemName: "figure.outdoor.cycle")
         }
         .padding(.trailing)
         }
         })
         */
        .cornerRadius(10)
        .onTapGesture {
            withAnimation(.spring()) {
                if onboardingStage == 5 {
                    dismiss()
                } else {
                    onboardingStage += 1
                }
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

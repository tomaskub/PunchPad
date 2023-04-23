//
//  EditSheetView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/18/23.
//

import SwiftUI

struct EditSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
//    @State var entry: Entry
    @StateObject var viewModel: EditSheetViewModel
    var body: some View {
        ZStack {
            
            LinearGradient(colors: [ colorScheme == .light ? .white : .black, .blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack{
                
            
                ZStack {
                    
                    RingView(progress: $viewModel.workTimeFraction, ringColor: .blue, displayPointer: false)
                    
                    RingView(progress: $viewModel.overTimeFraction, ringColor: .green, displayPointer: false)
                        .padding(30)
                    
                }
                .frame(width: 250, height: 250)
                .padding(.bottom)
                
                
                
                DatePicker("Start date", selection: $viewModel.startDate)
                
                DatePicker("Finish date:", selection: $viewModel.finishDate)
                
                Divider()
                
                HStack {
                    Text("Time worked:")
                    Spacer()
                    Text(viewModel.workTimeString)
                        .padding(EdgeInsets(top: 4, leading: 28, bottom: 4, trailing: 28))
                        .background {
                            Rectangle()
                                .cornerRadius(8)
                            .opacity(0.05)}
                    
                }
                .padding(.top)
                
                HStack {
                    Text("Overtime:")
                    Spacer()
                    Text(viewModel.overTimerString)
                        .padding(EdgeInsets(top: 4, leading: 28, bottom: 4, trailing: 28))
                        .background {
                            Rectangle()
                                .cornerRadius(8)
                            .opacity(0.05)}
                    
                    
                }
                .padding(.top)
                
                Divider()
                
                HStack {
                    Button {
                        viewModel.saveEntry()
                        dismiss()
                    } label: {
                        Text("SAVE")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 140, height: 38)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.blue)
                                
                            }
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("CANCEL")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 140, height: 38)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.gray)
                            }
                    }
                }
                .padding(.top)
                
            }
            .padding(.horizontal)
        }
    }
}
struct EditSheetView_Previews: PreviewProvider {
    static var previews: some View {
        EditSheetView(viewModel:
                        EditSheetViewModel.preview
        )
    }
}

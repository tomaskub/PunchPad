//
//  EditSheetView.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/18/23.
//

import SwiftUI

struct EditSheetView: View {
    
//    @State var entry: Entry
    @StateObject var viewModel: EditSheetViewModel
    var body: some View {
        
            VStack{
                
                DatePicker("Start date", selection: $viewModel.startDate)
                DatePicker("Finish date:", selection: $viewModel.finishDate)
                
                Text("Time worked: \(viewModel.workTimeInSeconds / 3600)")
                Text("Overtime: \(viewModel.overTimeInSeconds / 3600)")
            }
            .padding(.horizontal)
        
    }
}
struct EditSheetView_Previews: PreviewProvider {
    static var previews: some View {
        EditSheetView(viewModel:
                        EditSheetViewModel(
                            dataManager: DataManager.preview, entry: Entry()
                        )
        )
    }
}

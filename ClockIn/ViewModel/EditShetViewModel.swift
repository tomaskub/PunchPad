//
//  EditShetViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/18/23.
//

import Foundation

class EditSheetViewModel: ObservableObject {
    
    private var dataManager: DataManager
    private var entry: Entry
    private var workTimeAllowed: Int
    
    @Published var startDate: Date {
        didSet {
            calculateTime()
        }
    }
    @Published var finishDate: Date {
        didSet {
            calculateTime()
        }
    }
    
    @Published var workTimeInSeconds: Int
    @Published var overTimeInSeconds: Int
    
    
    
    init(dataManager: DataManager = DataManager.shared, entry: Entry) {
        self.dataManager = dataManager
        self.entry = entry
        
        self.startDate = entry.startDate
        self.finishDate = entry.finishDate
        self.workTimeInSeconds = entry.workTimeInSeconds
        self.overTimeInSeconds = entry.overTimeInSeconds
        
        self.workTimeAllowed = UserDefaults.standard.integer(forKey: K.UserDefaultsKeys.workTimeInSeconds)
    }
    
    func calculateTime() {
        let timeInterval = Calendar.current.dateComponents([.second], from: startDate, to: finishDate)
        if let seconds = timeInterval.second {
            if seconds <= workTimeAllowed {
                workTimeInSeconds = seconds
            } else {
                workTimeInSeconds = workTimeAllowed
                overTimeInSeconds = seconds - workTimeAllowed
            }
        }
    }
    
}

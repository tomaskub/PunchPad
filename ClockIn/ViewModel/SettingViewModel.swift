//
//  SettingViewModel.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 4/3/23.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    
    
    
    
    //View states
    @Published var isShowingWorkTimeEditor: Bool = false
    @Published var isShowingOverTimeEditor: Bool = false
    
    private var dataManager: DataManager
    
    @Published var timerHours: Int = 8 {
        didSet {
            workTimeInSeconds = Double(timerHours * 360 + timerMinutes * 60)
        }
    }
    @Published var timerMinutes: Int = 30 {
        didSet {
            workTimeInSeconds = Double(timerHours * 360 + timerMinutes * 60)
        }
    }
        
    
    //UserDefaults
    @Published var isLoggingOverTime: Bool = false {
        didSet {
            //On didSet write to userDefaults
            UserDefaults.standard.set(isLoggingOverTime, forKey: "isLoggingOverTime")
        }
    }
    @Published var preferredColorScheme: String = "system" {
        didSet {
            UserDefaults.standard.set(preferredColorScheme, forKey: "colorScheme")
        }
    }
    @Published var maximumOvertimeAllowed: Double = 5.0 {
        didSet {
            UserDefaults.standard.set(maximumOvertimeAllowed, forKey: "overtimeMaximum")
        }
    }
    @Published var isSendingNotifications: Bool = true {
        didSet {
            UserDefaults.standard.set(isSendingNotifications, forKey: "isSendingNotifications")
        }
    }
    private var workTimeInSeconds: Double = 28800 {
        didSet {
            UserDefaults.standard.set(workTimeInSeconds, forKey: "workTimeInSeconds")
        }
    }
    
    init(dataManger: DataManager = DataManager.shared ) {
        self.dataManager = dataManger
        //        on init retrieve values
        self.isLoggingOverTime = UserDefaults.standard.bool(forKey: "isLoggingOverTime")
        self.preferredColorScheme = UserDefaults.standard.string(forKey: "colorScheme") ?? "system"
        self.maximumOvertimeAllowed = UserDefaults.standard.double(forKey: "overtimeMaximum")
        self.workTimeInSeconds = UserDefaults.standard.double(forKey: "workTimeInSeconds")
        self.timerHours = Int(workTimeInSeconds / 360)
        self.timerMinutes = Int(workTimeInSeconds.truncatingRemainder(dividingBy: 360) / 60)
    }
    
    func deleteAllData() {
        dataManager.deleteAll()
    }
    
    func resetUserDefaults() {
        isLoggingOverTime = true
        preferredColorScheme = "system"
        maximumOvertimeAllowed = 5
        isSendingNotifications =  true
    }
}

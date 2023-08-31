//
//  ScreenIdentifier.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 31/08/2023.
//

import Foundation

enum ScreenIdentifier {
    
    enum HomeView: String {
        case startStopButton
        case resumePauseButton
        case timerLabel
        case statisticsNavigationButton
        case settingNavigationButton
    }
    
    enum StatisticsView {
        
        enum Chart: String {
            case workTimeChart
            case startTimeChart
            case finishTimeChart
        }
        
        enum ChartTypePicker: String {
            case workTime
            case startTime
            case finishTime
        }
        
        enum ChartLegend: String {
            case workTimeChartLegend
            case startTimeChartLegend
            case finishTimeChartLegend
        }
        
        enum SalaryCalculationLabel: String {
            case grossPay
            case netPay
        }
        
        enum NavigationBarButtons: String {
            case detailedHistory
            case back
        }
    }
    
    enum SettingsView {
        
        enum ExpandableCells: String {
            case setTimerLength
            case setOvertimeLength
        }
        
        enum SectionHeaders: String {
            case timerSettings
            case overtimeSettings
            case paycheckCalculation
            case userData
            case appearance
        }
        
        enum Pickers: String {
            case timePicker
            case overtimePicker
            case appearancePicker
        }
        
        enum ToggableCells: String {
            case sendNotificationsOnFinish
            case keepLoggingOvertime
            case calculateNetPay
        }
        
        enum ButtonCells: String {
            case clearAllSavedData
            case resetPreferences
        }
    }
}

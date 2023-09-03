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
        
        enum SegmentedControl: String {
            case chartType
        }
        
        enum ChartTypeButton: String {
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
        
        enum SectionHeaders: String {
            case chart
            case salaryCalculation
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
        
        enum TextFields: String {
            case calculateNetPay
        }
    }
    
    enum OnboardingView {
        
        enum Pickers: String {
            case workingHours
            case workingMinutes
            case overtimeHours
            case overtimeMinutes
        }
        
        enum TextFields: String {
            case grossPaycheck
        }
        
        enum Toggles: String {
            case overtime
            case notifications
            case calculateNetSalary
        }
        
        enum Buttons: String {
            case advanceStage
            case regressStage
        }
    }
}

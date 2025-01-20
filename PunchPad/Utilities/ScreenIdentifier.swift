//
//  ScreenIdentifier.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 31/08/2023.
//

import Foundation

enum ScreenIdentifier {
    
    enum NavigationElements {
        enum NavigationBarButtons: String {
            case settingNavigationButton
            case detailedHistory
            case back
        }
        
        enum TabBarButtons: String {
            case home
            case statistics
            case history
        }
    }
    
    enum HomeView: String {
        case startButton
        case pauseButton
        case resumeButton
        case finishButton
        case timerLabel
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
            case timeHoursPicker
            case timeMinutesPicker
            case overtimeHoursPicker
            case overtimeMinutesPicker
            case appearancePicker
        }
        
        enum SegmentedControlButtons: String {
            case system
            case dark
            case light
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
            case grossPay
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
    
    enum HistoryView: String {
        case addEntryButton
        case deleteEntryButton
        case editEntryButton
        case entryRow
        case filterButton
    }
    
    enum HistoryRowView {
        enum Label: String {
            case dateLabel
            case timeWorkedLabel
            case startTimeValueLabel
            case finishTimeValueLabel
        }
        
        enum DetailView: String {
            case circleDetail
            case barDetail
        }
    }
    
    enum EditSheetView {
        enum Label: String {
            case timeWorkedValue
            case overtimeValue
        }
        
        enum DatePicker: String {
            case startDate
            case finishDate
        }
        
        enum Button: String {
            case save
            case cancel
        }
    }
}

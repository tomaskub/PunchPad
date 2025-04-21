//
//  ScreenIdentifier.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 31/08/2023.
//

// swiftlint:disable nesting
public enum ScreenIdentifier {
    public enum NavigationElements {
            public enum NavigationBarButtons: String {
                case settingNavigationButton
                case detailedHistory
                case back
            }
            
            public enum TabBarButtons: String {
                case home
                case statistics
                case history
            }
        }

    public enum HomeView: String {
        case startButton
        case pauseButton
        case resumeButton
        case finishButton
        case timerLabel
    }
    
    public enum StatisticsView: String {
        case workTimeChart
        
        public enum SegmentedControl: String {
            case allRange
            case yearRange
            case monthRange
            case weekRange
        }
        
        public enum SalaryCalculationLabel: String {
            case period
            case grossPayPerHour
            case grossPay
            case grossPayPredicted
            case workingDaysNumber
        }
        
        public enum SectionHeaders: String {
            case salaryCalculation
        }
    }
    
    public enum SettingsView {
        public enum ExpandableCells: String {
            case setTimerLength
            case setOvertimeLength
        }
        
        public enum SectionHeaders: String {
            case timerSettings
            case overtimeSettings
            case paycheckCalculation
            case userData
            case appearance
        }
        
        public enum Pickers: String {
            case timeHoursPicker
            case timeMinutesPicker
            case overtimeHoursPicker
            case overtimeMinutesPicker
            case appearancePicker
        }
        
        public enum SegmentedControlButtons: String {
            case system
            case dark
            case light
        }
        
        public enum ToggableCells: String {
            case sendNotificationsOnFinish
            case keepLoggingOvertime
            case calculateNetPay
        }
        
        public enum ButtonCells: String {
            case clearAllSavedData
            case resetPreferences
        }
        
        public enum TextFields: String {
            case grossPay
        }
    }
    
    public enum OnboardingView {
        public enum Pickers: String {
            case workingHours
            case workingMinutes
            case overtimeHours
            case overtimeMinutes
        }
        
        public enum TextFields: String {
            case grossPaycheck
        }
        
        public enum Toggles: String {
            case overtime
            case notifications
            case calculateNetSalary
        }
        
        public enum Buttons: String {
            case advanceStage
            case regressStage
        }
    }
    
    public enum HistoryView: String {
        case addEntryButton
        case deleteEntryButton
        case editEntryButton
        case entryRow
        case filterButton
        case emptyPlaceholder
        
        public enum ConfirmDeleteDialogView: String {
            case okButton
            case cancelButton
            case dialogLabel
        }
    }
    
    public enum HistoryRowView {
        public enum Label: String {
            case dateLabel
            case timeWorkedLabel
            case startTimeValueLabel
            case finishTimeValueLabel
        }
        
        public enum DetailView: String {
            case circleDetail
            case barDetail
        }
    }
    
    public enum EditSheetView {
        public enum Label: String {
            case worktimeValue
            case overtimeValue
            case breaktimeValue
        }
        
        public enum DatePicker: String {
            case startDate
            case finishDate
            case date
            case startTime
            case finishTime
        }
        
        public enum Button: String {
            case save
            case cancel
        }
    }
}
// swiftlint:enable nesting

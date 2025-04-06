//
//  Localization.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 20/04/2024.
//
// swiftlint:disable line_length
import Foundation

public struct Localization {
    public struct Common {
        public static let hours = String(localized: "hours")
        public static let minutes = String(localized: "minutes")
        public static let minutesShort = String(localized: "min")
        public static let overtime = String(localized: "overtime")
        public static let worktime = String(localized: "worktime")
        public static let ok = String(localized: "ok")
        public static let cancel = String(localized: "cancel")
        public static let apply = String(localized: "apply")
        public static let save = String(localized: "save")
        public static let next = String(localized: "next")
        public static let back = String(localized: "back")
        public static let start = String(localized: "start")
        public static let finish = String(localized: "finish")
    }
    public struct OnboardingScreen {
        public static let letsStart = String(localized: "Let's start!")
        public static let finishSetUp = String(localized: "Finish set up!")
    }
    
    public struct OnboardingWelcomeScreen {
        public static let description = String(localized: "This app was built to help you track time and make sure you are spending at work exactly the time you want and need. \n\n Plan your workdays and plan your paycheck!")
    }
    
    public struct OnboardingWorktimeScreen {
        public static let workday = String(localized: "workday")
        public static let description = String(localized: "PunchPad needs to know your normal workday length to let you know when you are done or when you enter into overtime")
    }
    
    public struct OnboardingOvertimeScreen {
        public static let letMeasureOvertime = "Let PunchPad know wheter you want to measure overtime"
        public static let letKnowMaximumOvertime = String(localized: "Let the app know maximum overtime you can work for.")
        public static let keepLoggingOvertime = String(localized: "Keep logging overtime")
    }
    
    public struct OnboardingNotificationScreen {
        public static let notifications = String(localized: "Notifications")
        public static let descriptionText = String(localized: "Do you want PunchPad to send you notifications when the work time is finished?")
        public static let sendNotificationsOnFinish = String(localized: "Send notifications on finish")
        public static let needsPermission = String(localized: "PunchPad needs permission to show notifications")
        public static let allowForNotifications = String(localized: "You need to allow for notification in settings")
    }
    
    public struct OnboardingSalaryScreen {
        public static let salary = String(localized: "Salary")
        public static let letKnowIncome = String(localized: "To let PunchPad calculate your salary you need to enter your gross montly income")
        public static let wantTocalculateNetSalaru = String(localized: "Do you want to PunchPad to calculate your net salary based on Polish tax law?")
        public static let grossPaycheck = String(localized: "Gross paycheck")
        public static let calculateNetSalary = String(localized: "Calculate net salary")
    }
    
    public struct AppNotificationScreen {
        public static let worktimeFinished = String(localized: "Work finished!")
        public static let overtimeFinished = String(localized: "Overtime finished!")
        public static let congratulationsYouFinishedNormalHours = String(localized: "Congratulations! You are finished with your normal hours!")
        public static let congratulationsYouFinishedOvertime = String(localized: "Congratulations! You finished with your overtime!")
    }
    
    public struct ChartLegendScreen {
        public static let legend = String(localized: "Legend:")
    }
    
    public struct StatisticsScreen {
        public static let salaryCalculation = String(localized: "Salary calculation")
        public static let timeWorked = String(localized: "time worked")
        public static let period = String(localized: "Period")
        public static let grossPayPerHour = String(localized: "Gross pay per hour")
        public static let grossPay = String(localized: "Gross pay")
        public static let grossPayPredicted = String(localized: "Gross pay predicted")
        public static let numberOfWorkingDays = String(localized: "Number of working days")
    }
    
    public struct SettingsScreen {
        public static let settings = String(localized: "Settings")
        public static let needsPermissionToShowNotifications = String(localized: "PunchPad needs permission to show notifications")
        public static let youNeedToAllowForNotifications = String(localized: "You need to allow for notification in settings")
        public static let setTimerLength = String(localized: "Set timer length")
        public static let maximumOvertimeAllowed = String(localized: "Maximum overtime allowed")
        public static let clearAllSavedData = String(localized: "Clear all saved data")
        public static let resetPreferences = String(localized: "Reset preferences")
        public static let keepLogingOvertime = String(localized: "Keep logging overtime")
        public static let grossPaycheck = String(localized: "Gross paycheck")
        public static let calculateNetPay = String(localized: "Calculate net pay")
        public static let colorScheme = String(localized: "Color scheme")
        public static let dark = String(localized: "Dark")
        public static let light = String(localized: "Light")
        public static let system = String(localized: "System")
        public static let sendNotificationsOnFinish = String(localized: "Send notification on finish")
        public static let timerSettings = String(localized: "Timer settings")
        public static let paycheckCalculation = String(localized: "Paycheck calculation")
        public static let userData = String(localized: "User data")
        public static let appearance = String(localized: "Appearance")
    }
    
    public struct HistoryScreen {
        public static let history = String(localized: "History")
        public static let opsSomethingWentWrong = String(localized: """
                    Ooops! Something went wrong,
                    or you never recorded time...
                    """ )
        public static let somethingWentWrong = String(localized: "Something went wrong")
        public static let areYouSure = String(localized: "Are you sure you want to delete this entry?")
    }
    
    public struct EditSheetScreen {
        public static let regularTime = String(localized: "Regular time")
        public static let breaktime = String(localized: "Break time")
        public static let editEntry = String(localized: "Edit entry")
        public static let overrideSettings = String(localized: "override settings")
        public static let date = String(localized: "Date")
        public static let maximumOvertime = String(localized: "Maximum overtime")
        public static let standardWorkTime = String(localized: "Standard work time")
        public static let grossPayPerMonth = String(localized: "Gross pay per month")
        public static let calculateNetPay = String(localized: "Calculate net pay")
    }
    
    public struct DateFilterSheetScreen {
        public static let filter = String(localized: "Filter")
        public static let to = String(localized: "To:")
        public static let from = String(localized: "From:")
        public static let oldestEntriesFirst = String(localized: "Oldest entries first")
    }
    
    public struct HomeScreen {
        public static let startYourWorkDay = String(localized: "Start your work day")
    }
}
// swiftlint:enable line_length

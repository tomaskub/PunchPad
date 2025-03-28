//
//  Localization.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 20/04/2024.
//
// swiftlint:disable line_length
import Foundation

struct Localization {
    struct Common {
        static let hours = String(localized: "hours")
        static let minutes = String(localized: "minutes")
        static let minutesShort = String(localized: "min")
        static let overtime = String(localized: "overtime")
        static let worktime = String(localized: "worktime")
        static let ok = String(localized: "ok")
        static let cancel = String(localized: "cancel")
        static let apply = String(localized: "apply")
        static let save = String(localized: "save")
        static let next = String(localized: "next")
        static let back = String(localized: "back")
        static let start = String(localized: "start")
        static let finish = String(localized: "finish")
    }
    struct OnboardingScreen {
        static let letsStart = String(localized: "Let's start!")
        static let finishSetUp = String(localized: "Finish set up!")
    }
    
    struct OnboardingWelcomeScreen {
        static let description = String(localized: "This app was built to help you track time and make sure you are spending at work exactly the time you want and need. \n\n Plan your workdays and plan your paycheck!")
    }
    
    struct OnboardingWorktimeScreen {
        static let workday = String(localized: "workday")
        static let description = String(localized: "PunchPad needs to know your normal workday length to let you know when you are done or when you enter into overtime")
    }
    
    struct OnboardingOvertimeScreen {
        static let letMeasureOvertime = "Let PunchPad know wheter you want to measure overtime"
        static let letKnowMaximumOvertime = String(localized: "Let the app know maximum overtime you can work for.")
        static let keepLoggingOvertime = String(localized: "Keep logging overtime")
    }
    
    struct OnboardingNotificationScreen {
        static let notifications = String(localized: "Notifications")
        static let descriptionText = String(localized: "Do you want PunchPad to send you notifications when the work time is finished?")
        static let sendNotificationsOnFinish = String(localized: "Send notifications on finish")
        static let needsPermission = String(localized: "PunchPad needs permission to show notifications")
        static let allowForNotifications = String(localized: "You need to allow for notification in settings")
    }
    
    struct OnboardingSalaryScreen {
        static let salary = String(localized: "Salary")
        static let letKnowIncome = String(localized: "To let PunchPad calculate your salary you need to enter your gross montly income")
        static let wantTocalculateNetSalaru = String(localized: "Do you want to PunchPad to calculate your net salary based on Polish tax law?")
        static let grossPaycheck = String(localized: "Gross paycheck")
        static let calculateNetSalary = String(localized: "Calculate net salary")
    }
    
    struct AppNotificationScreen {
        static let worktimeFinished = String(localized: "Work finished!")
        static let overtimeFinished = String(localized: "Overtime finished!")
        static let congratulationsYouFinishedNormalHours = String(localized: "Congratulations! You are finished with your normal hours!")
        static let congratulationsYouFinishedOvertime = String(localized: "Congratulations! You finished with your overtime!")
    }
    
    struct ChartLegendScreen {
        static let legend = String(localized: "Legend:")
    }
    
    struct StatisticsScreen {
        static let salaryCalculation = String(localized: "Salary calculation")
        static let timeWorked = String(localized: "time worked")
        static let period = String(localized: "Period")
        static let grossPayPerHour = String(localized: "Gross pay per hour")
        static let grossPay = String(localized: "Gross pay")
        static let grossPayPredicted = String(localized: "Gross pay predicted")
        static let numberOfWorkingDays = String(localized: "Number of working days")
    }
    
    struct SettingsScreen {
        static let settings = String(localized: "Settings")
        static let needsPermissionToShowNotifications = String(localized: "PunchPad needs permission to show notifications")
        static let youNeedToAllowForNotifications = String(localized: "You need to allow for notification in settings")
        static let setTimerLength = String(localized: "Set timer length")
        static let maximumOvertimeAllowed = String(localized: "Maximum overtime allowed")
        static let clearAllSavedData = String(localized: "Clear all saved data")
        static let resetPreferences = String(localized: "Reset preferences")
        static let keepLogingOvertime = String(localized: "Keep logging overtime")
        static let grossPaycheck = String(localized: "Gross paycheck")
        static let calculateNetPay = String(localized: "Calculate net pay")
        static let colorScheme = String(localized: "Color scheme")
        static let dark = String(localized: "Dark")
        static let light = String(localized: "Light")
        static let system = String(localized: "System")
        static let sendNotificationsOnFinish = String(localized: "Send notification on finish")
        static let timerSettings = String(localized: "Timer settings")
        static let paycheckCalculation = String(localized: "Paycheck calculation")
        static let userData = String(localized: "User data")
        static let appearance = String(localized: "Appearance")
    }
    
    struct HistoryScreen {
        static let history = String(localized: "History")
        static let opsSomethingWentWrong = String(localized: """
                    Ooops! Something went wrong,
                    or you never recorded time...
                    """ )
        static let somethingWentWrong = String(localized: "Something went wrong")
        static let areYouSure = String(localized: "Are you sure you want to delete this entry?")
    }
    
    struct EditSheetScreen {
        static let regularTime = String(localized: "Regular time")
        static let breaktime = String(localized: "Break time")
        static let editEntry = String(localized: "Edit entry")
        static let overrideSettings = String(localized: "override settings")
        static let date = String(localized: "Date")
        static let maximumOvertime = String(localized: "Maximum overtime")
        static let standardWorkTime = String(localized: "Standard work time")
        static let grossPayPerMonth = String(localized: "Gross pay per month")
        static let calculateNetPay = String(localized: "Calculate net pay")
    }
    
    struct DateFilterSheetScreen {
        static let filter = String(localized: "Filter")
        static let to = String(localized: "To:")
        static let from = String(localized: "From:")
        static let oldestEntriesFirst = String(localized: "Oldest entries first")
    }
    
    struct HomeScreen {
        static let startYourWorkDay = String(localized: "Start your work day")
    }
}
// swiftlint:enable line_length

//
//  updateAnticoagulantReminder.swift
//  mInr
//
//  Created by Finn LeSueur on 26/11/23.
//

import Foundation
import SwiftUI
import UserNotifications
import os

enum NotificationAction {
    case doneAction
    case repeatAction
    case repeatOneLessAction
    case repeatOneMoreAction

    var id: String {
        switch self {
        case .doneAction:
            return "doneAction"
        case .repeatAction:
            return "repeatAction"
        case .repeatOneLessAction:
            return "repeatOneLessAction"
        case .repeatOneMoreAction:
            return "repeatOneMoreAction"
        }
    }
}

class NotificationsViewController: UIViewController, UNUserNotificationCenterDelegate {
    @ObservedObject var prefs = Prefs.shared
    @ObservedObject var dataModel = DataManager.shared
    
    func updateWarfarinReminder() {
        Logger().info("Reminder: updateWarfarinReminder()")
        
        // If reminders are disabled, clear all pending
        // reminders and exit.
        if (!prefs.warfarinReminderEnabled) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [prefs.warfarinReminderIdentifier])
            Logger().info("Reminder: Notifications are disabled --> pending notifications are removed.")
            return
        }
        
        // Reminders are enabled, so clear pending requests
        // and create a new one with fresh information.
        
        // Remove old timer
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        //        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [prefs.warfarinReminderIdentifier])
        
        // Last dose
        let lastDose = dataModel.mostRecentAnticoagulantDose()
        var lastDoseString: String
        if lastDose.count == 1 {
            lastDoseString = "Your last dose was \(lastDose[0].dose)mg."
        } else {
            lastDoseString = ""
        }
        
        // Create new timer
        let content = UNMutableNotificationContent()
        content.title = "mINR"
        content.body = "Take \(prefs.primaryAntiCoagulantName). \(lastDoseString)"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "anticoagulantReminderCategory"
        content.threadIdentifier = "minr.anticoagulantReminder"
        let components = Calendar.current.dateComponents([.hour, .minute], from: prefs.warfarinReminderTime)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        prefs.warfarinReminderIdentifier = request.identifier // Store identifier
        
        // Add timer
        UNUserNotificationCenter.current().add(request)
        Logger().info("Reminder: \(lastDoseString) @ \(components)")
    }
    
    // Register notification categories
    func registerCategories() {
        UNUserNotificationCenter.current().delegate = self
        
        let repeatOneLessAction = UNNotificationAction(identifier: "repeatOneLessAction", title: "Repeat -1mg", options: [])
        let repeatAction = UNNotificationAction(identifier: "repeatAction", title: "Repeat Same Dose", options: [])
        let repeatOneMoreAction = UNNotificationAction(identifier: "repeatOneMoreAction", title: "Repeat +1mg", options: [])

        let anticoagulantReminderCategory = UNNotificationCategory(
            identifier: "anticoagulantReminderCategory",
            actions: [repeatOneLessAction, repeatAction, repeatOneMoreAction],
            intentIdentifiers: [],
            options: [])

        UNUserNotificationCenter.current().setNotificationCategories([anticoagulantReminderCategory])
    }
    
    // Receives the action taken from
    // the notification.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Logger().info("Reminder userNotificationCenter: Notification handler called")
        
        var dose: Int32 = dataModel.mostRecentAnticoagulantDose()[0].dose
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // The user swiped to unlock
            Logger().info("Reminder userNotificationCenter: Default action --> open app")
        case "repeatAction":
            Logger().info("Reminder userNotificationCenter: repeatAction --> add same dose as previous")
            dose = dataModel.mostRecentAnticoagulantDose()[0].dose
        case "repeatOneLessAction":
            Logger().info("Reminder userNotificationCenter: repeatOneLessAction --> add yesterdays dose -1mg")
            dose = dataModel.mostRecentAnticoagulantDose()[0].dose - 1
        case "repeatOneMoreAction":
            Logger().info("Reminder userNotificationCenter: repeatOneMoreAction --> add yesterdays dose +1mg")
            dose = dataModel.mostRecentAnticoagulantDose()[0].dose + 1
        default:
            Logger().info("Reminder userNotificationCenter: default action")
            break
        }
        
        do {
            _ = try dataModel.addAntiCoagulantDose(
                dose: dose,
                secondaryDose: 0,
                note: "",
                timestamp: Date.now
            )
            NotificationsViewController().updateWarfarinReminder()
        } catch let error {
            Logger().error("Reminder userNotificationCenter: couldn't add anticoagulantdose. \(error.localizedDescription)")
        }
        
        completionHandler()
    }
}

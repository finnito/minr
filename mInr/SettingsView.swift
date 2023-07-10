//
//  SettingsView.swift
//  mInr
//
//  Created by Finn LeSueur on 19/02/23.
//

import SwiftUI
import UserNotifications
import WidgetKit

struct SettingsView: View {
    @ObservedObject var prefs = Prefs.shared

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Primary Anticoagulant")) {
                        HStack {
                            Text("Medication Name: ")
                            TextField(
                                "Warfarin",
                                text: prefs.$primaryAntiCoagulantName
                            )
                        }
                    }
                    
                    Section(header: Text("Secondary Anticoagulant")) {
                        Toggle("Enabled", isOn: prefs.$secondaryAntiCoagulantEnabled)
                        HStack {
                            Text("Medication Name: ")
                            TextField(
                                "Aspirin",
                                text: prefs.$secondaryAntiCoagulantName
                            )
                        }.disabled(!prefs.secondaryAntiCoagulantEnabled)
                    }
                    
                    Section(header: Text("INR Range")) {
                        HStack {
                            Text("Min:")
                            TextField(
                                "3.5",
                                value: prefs.$minimumINR,
                                format: .number
                            )
                            .keyboardType(.numberPad)
                            .onChange(of: prefs.minimumINR) { newMinimumINR in
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                        }
                        HStack {
                            Text("Max:")
                            TextField(
                                "3.5",
                                value: prefs.$maximumINR,
                                format: .number
                            )
                            .keyboardType(.numberPad)
                        }
                    }
                    
                    
                    Section(header: Text("Graph Range")) {
                        HStack {
                            Text("Range:")
                            Spacer()
                            TextField(
                                "14",
                                value: prefs.$graphRange,
                                format: .number
                            )
                            .keyboardType(.numberPad)
                            Text("days")
                        }
                    }
                    
                    
                    Section(header: Text("Medication Reminder")) {
                        Toggle("Enabled", isOn: prefs.$warfarinReminderEnabled.onChange(updateWarfarinReminder))
                        HStack {
                            DatePicker(
                                "Time",
                                selection: prefs.$warfarinReminderTime.onChange(updateWarfarinReminder),
                                displayedComponents: [.hourAndMinute]
                            )
                        }.disabled(!prefs.warfarinReminderEnabled)
                    }
                    
                    Section(header: Text("Accent Colour")) {
                        ColorPicker(
                            "Light Accent Colour",
                            selection: prefs.$lightAccentColour,
                            supportsOpacity: true
                        )
                        ColorPicker(
                            "Dark Accent Colour",
                            selection: prefs.$darkAccentColour,
                            supportsOpacity: true
                        )
                    }
                    
                    Section(header: Text("Data Export")) {
                        NavigationLink(destination: DataExportView()) {
                            Text("Export Data")
                        }
                    }
                }
            }
        }.navigationTitle("Settings")
    }
    
    func updateWarfarinReminder() {
        if (!prefs.warfarinReminderEnabled) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [prefs.warfarinReminderIdentifier])
            return
        }
        
        // Remove old timer
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [prefs.warfarinReminderIdentifier])
        
        // Last dose
        let lastDose = DataManager.shared.mostRecentAnticoagulantDose()
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
        let components = Calendar.current.dateComponents([.hour, .minute], from: prefs.warfarinReminderTime)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        prefs.warfarinReminderIdentifier = request.identifier // Store identifier
        
        // Add timer
        UNUserNotificationCenter.current().add(request)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

//
//  SettingsView.swift
//  mInr
//
//  Created by Finn LeSueur on 19/02/23.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    // Stored preferences
    @AppStorage("primaryAntiCoagulantName") var primaryAntiCoagulantName: String = "Warfarin"
    @AppStorage("primaryAntiCoagulantDose") var primaryAntiCoagulantDose: Int = 4
    @AppStorage("maximumINRRange") var maximumINR: Double = 3.5
    @AppStorage("minimumINRRange") var minimumINR: Double = 2.5
    @AppStorage("graphRange") var graphRange: Int = 14
    
    @AppStorage("warfarinReminderEnabled") var warfarinReminderEnabled: Bool = false
    @AppStorage("warfarinReminderTime") var warfarinReminderTime = Date()
    @AppStorage("warfarinReminderInterval") var warfarinReminderInterval: Int = 1
    @AppStorage("warfarinReminderIdentifier") var warfarinReminderIdentifier: String = ""
    
//    @AppStorage("inrReminderEnabled") var inrReminderEnabled: Bool = false
//    @AppStorage("inrReminderTime") var inrReminderTime = Date()
//    @AppStorage("inrReminderInterval") var inrReminderInterval: Int = 7
//    @AppStorage("inrReminderIdentifier") var inrReminderIdentifier: String = ""
    
    @AppStorage("lightAccentColour") var lightAccentColour: Color = .red
    @AppStorage("darkAccentColour") var darkAccentColour: Color = .yellow

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Primary Anticoagulant")) {
                        HStack {
                            Text("Medication Name")
                            TextField(
                                "Warfarin",
                                text: $primaryAntiCoagulantName
                            )
                        }
                        HStack {
                            Text("Dose")
                            TextField(
                                "4",
                                value: $primaryAntiCoagulantDose,
                                format: .number
                            )
                        }
                    }
                    Section(header: Text("INR Range")) {
                        HStack {
                            Text("Min:")
                            TextField(
                                "3.5",
                                value: $minimumINR,
                                format: .number
                            )
                            .keyboardType(.numberPad)
                        }
                        HStack {
                            Text("Max:")
                            TextField(
                                "3.5",
                                value: $maximumINR,
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
                                value: $graphRange,
                                format: .number
                            )
                            .keyboardType(.numberPad)
                            Text("days")
                        }
                    }
                    
                    
                    Section(header: Text("\(primaryAntiCoagulantName) Reminder")) {
                        Toggle("Enabled", isOn: $warfarinReminderEnabled.onChange(updateWarfarinReminder))
                        HStack {
                            DatePicker(
                                "Time",
                                selection: $warfarinReminderTime.onChange(updateWarfarinReminder),
                                displayedComponents: [.hourAndMinute]
                            )
                        }.disabled(!warfarinReminderEnabled)
                    }
                    
//                    Section(header: Text("INR Reminder")) {
//                        Toggle("Enabled", isOn: $inrReminderEnabled.onChange(updateINRReminder))
//                        HStack {
//                            DatePicker(
//                                "Start",
//                                selection: $inrReminderTime.onChange(updateINRReminder),
//                                displayedComponents: [.hourAndMinute]
//                            )
//                        }.disabled(!inrReminderEnabled)
//                        HStack {
//                            Text("Interval:")
//                            TextField(
//                                "7",
//                                value: $inrReminderInterval.onChange(updateINRReminder),
//                                format: .number
//                            ).keyboardType(.numberPad)
//                            Text("days")
//                        }.disabled(!inrReminderEnabled)
//                    }
                    
                    Section(header: Text("Accent Colour")) {
                        ColorPicker(
                            "Light Accent Colour",
                            selection: $lightAccentColour,
                            supportsOpacity: true
                        )
                        ColorPicker(
                            "Dark Accent Colour",
                            selection: $darkAccentColour,
                            supportsOpacity: true
                        )
                    }
                }
            }
        }.navigationTitle("Settings")
    }
    
//    func updateINRReminder() {
//        if (!inrReminderEnabled) {
//            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [inrReminderIdentifier])
////            printUpcomingReminders()
//            return
//        }
//        
//        // Remove old timer
//        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [inrReminderIdentifier])
//        
//        // Create new timer
//        let content = UNMutableNotificationContent()
//        content.title = "mINR"
//        content.body = "Check your INR."
//        content.sound = UNNotificationSound.default
//        var components = Calendar.current.dateComponents([.hour, .minute], from: inrReminderTime)
//        components.weekday = 1
//        components.weekOfMonth = 2
//        let trigger = UNCalendarNotificationTrigger(
//            dateMatching: components,
//            repeats: true
//        )
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//        inrReminderIdentifier = request.identifier // Store identifier
//        
//        // Add timer
//        UNUserNotificationCenter.current().add(request)
//        
////        printUpcomingReminders()
//        
//    }
    
    func updateWarfarinReminder() {
        if (!warfarinReminderEnabled) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [warfarinReminderIdentifier])
//            printUpcomingReminders()
            return
        }
        
        // Remove old timer
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [warfarinReminderIdentifier])
        
        // Create new timer
        let content = UNMutableNotificationContent()
        content.title = "mINR"
        content.body = "Take warfarin."
        content.sound = UNNotificationSound.default
        let components = Calendar.current.dateComponents([.hour, .minute], from: warfarinReminderTime)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        warfarinReminderIdentifier = request.identifier // Store identifier
        
        // Add timer
        UNUserNotificationCenter.current().add(request)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

//
//  File.swift
//  mInr
//
//  Created by Finn LeSueur on 14/12/23.
//

import SwiftUI
import WidgetKit

struct FirstRunView: View {
    @ObservedObject var prefs = Prefs.shared
    
    var body: some View {
        VStack {

            
            Form {
                HStack {
                    Text("mINR")
                        .font(.largeTitle)
                        .fontWeight(.black)
                    Spacer()
                    
                    if let iconName = UIApplication.shared.alternateIconName {
                        Image(uiImage: UIImage(named: iconName)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .cornerRadius(6)
                            .shadow(
                                color: Color.black.opacity(0.1),
                                radius: 5,
                                x: 0, y: 0)
                    } else {
                        Image(uiImage: UIImage(named: "AppIcon")!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .cornerRadius(6)
                            .shadow(
                                color: Color.black.opacity(0.1),
                                radius: 5,
                                x: 0, y: 0)
                    }
                    
                    
                }
                
                Text("Welcome to mINR (pronounced my-NR)! For a smooth start with this app please confirm a few settings.")
                
                Section(header: Label("Primary Anticoagulant", systemImage: K.SFSymbols.anticoagulant)) {
                    HStack {
                        Text("Medication Name: ")
                        TextField(
                            "Warfarin",
                            text: prefs.$primaryAntiCoagulantName
                        )
                        
                        .onChange(of: prefs.primaryAntiCoagulantName) {
                            WidgetCenter.shared.reloadAllTimelines()
                            print("WIDGETS: Asked to reload.")
                        }
                    }
                }
                
                Section(header: Label("INR Range", systemImage: K.SFSymbols.inr)) {
                    HStack {
                        Text("Min:")
                        TextField(
                            "3.5",
                            value: prefs.$minimumINR,
                            format: .number
                        )
                        .onChange(of: prefs.minimumINR) {
                            WidgetCenter.shared.reloadAllTimelines()
                            print("WIDGETS: Asked to reload.")
                        }
                    }
                    HStack {
                        Text("Max:")
                        TextField(
                            "3.5",
                            value: prefs.$maximumINR,
                            format: .number
                        )
                        .onChange(of: prefs.maximumINR) {
                            WidgetCenter.shared.reloadAllTimelines()
                            print("WIDGETS: Asked to reload.")
                        }
                    }
                }
                
                Section(header: Label("Medication Reminder", systemImage: K.SFSymbols.alarm)) {
                    Toggle("Enabled", isOn: prefs.$warfarinReminderEnabled)
                        .onChange(of: prefs.warfarinReminderEnabled) {
                            NotificationsViewController().updateWarfarinReminder()
                        }
                    HStack {
                        DatePicker(
                            "Time",
                            selection: prefs.$warfarinReminderTime,
                            displayedComponents: [.hourAndMinute]
                        )
                        .onChange(of: prefs.warfarinReminderTime) {
                            NotificationsViewController().updateWarfarinReminder()
                        }
                    }.disabled(!prefs.warfarinReminderEnabled)
                }
                
                Text("These settings are not permanent and may be altered at any time.")
                                
                Button {
                    prefs.showFirstRunView = false
                } label: {
                    HStack {
                        Spacer()
                        Text("Confirm")
                        Image(systemName: K.SFSymbols.save)
                    }
                }.foregroundColor(.blue)
            }
        }
    }
}

struct FirstRunView_Previews: PreviewProvider {
    static var previews: some View {
        FirstRunView()
    }
}

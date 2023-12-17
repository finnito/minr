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
                    
                    Section(header: Label("Secondary Medication", systemImage: K.SFSymbols.anticoagulant)) {
                        Toggle("Enabled", isOn: prefs.$secondaryAntiCoagulantEnabled)
                        HStack {
                            Text("Medication Name: ")
                            TextField(
                                "Aspirin",
                                text: prefs.$secondaryAntiCoagulantName
                            )
                            .onChange(of: prefs.secondaryAntiCoagulantName) {
                                WidgetCenter.shared.reloadAllTimelines()
                                print("WIDGETS: Asked to reload.")
                            }
                        }.disabled(!prefs.secondaryAntiCoagulantEnabled)
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
                    
                    Section(header: Label("App Accent Colour", systemImage: K.SFSymbols.color)) {
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
                    
                    Section(header: Label("Graph", systemImage: K.SFSymbols.graph)) {
                        Text("PREVIEW: Last \(prefs.graphRange) Days")
                            .fontWeight(.bold)
                            .listRowSeparator(.hidden)
                        WarfarinINRChart()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                .fill(colorScheme == .dark ? K.Colours.cardBackgroundDark : K.Colours.cardBackgroundLight)
                            )
                            .padding(.horizontal, 0)
                        
                        HStack {
                            Text("Range:")
                            Spacer()
                            TextField(
                                "14",
                                value: prefs.$graphRange,
                                format: .number
                            )
                            Text("days")
                        }
                        HStack {
                            Text("Point Spacing:")
                            Spacer()
                            TextField(
                                "14",
                                value: prefs.$chartPointWidth,
                                format: .number
                            )
                        }
                        HStack {
                            ColorPicker(
                                "Anticoagulant Colour",
                                selection: prefs.$chartAnticoagulantColor,
                                supportsOpacity: false
                            )
                            .onChange(of: prefs.chartAnticoagulantColor) {
                                WidgetCenter.shared.reloadAllTimelines()
                                print("WIDGETS: Asked to reload.")
                            }
                        }
                        HStack {
                            ColorPicker(
                                "Secondary Anticoagulant Colour",
                                selection: prefs.$chartSecondaryAnticoagulantColor,
                                supportsOpacity: false
                            )
                            .onChange(of: prefs.chartSecondaryAnticoagulantColor) {
                                WidgetCenter.shared.reloadAllTimelines()
                                print("WIDGETS: Asked to reload.")
                            }
                        }
                        HStack {
                            ColorPicker(
                                "INR Colour",
                                selection: prefs.$chartINRColor,
                                supportsOpacity: false
                            )
                            .onChange(of: prefs.chartINRColor) {
                                WidgetCenter.shared.reloadAllTimelines()
                                print("WIDGETS: Asked to reload.")
                            }
                        }
                        HStack {
                            ColorPicker(
                                "INR Range Colour",
                                selection: prefs.$chartINRRangeColor,
                                supportsOpacity: true
                            )
                            .onChange(of: prefs.chartINRRangeColor) {
                                WidgetCenter.shared.reloadAllTimelines()
                                print("WIDGETS: Asked to reload.")
                            }
                        }
                    }
                    
                    Section(header: Label("App Icon", systemImage: K.SFSymbols.icon)) {
                        ChangeAppIconView()
                    }
                    
                    Section(header: Label("Export Data", systemImage: K.SFSymbols.export)) {
                        NavigationLink(destination: DataExportView()) {
                            Text("Export Data")
                        }
                    }
                }
            }
        }.navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

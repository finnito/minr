//
//  Widget_Status-accessory.swift
//  mInr
//
//  Created by Finn LeSueur on 3/07/23.
//

import ActivityKit
import WidgetKit
import SwiftUI
import Intents
import Charts

struct WidgetStatusAccessory: Widget {
    let kind: String = "com.minr.widget_status_accessory"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StatusAccessoryWidgetTimelineProvider()
        ) { entry in
            StatusAccessoryWidgetView(entry: entry)
        }
        .configurationDisplayName("Status")
        .description("Display your anticoagulant and INR status at a glance.")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct StatusAccessoryWidgetView: View {
    let entry: StatusWidgetEntry
    var body: some View {
//        HStack {
        VStack(alignment: .leading) {
            // Warfarin Stack
            HStack() {
                Image(systemName: K.SFSymbols.anticoagulant)
                    .font(.system(size: 12))
                if entry.acdPlaceholder {
                    Text("NA")
                } else {
                    Text("\(entry.anticoagulantDose[0].dose)mg")
                }
                
                if entry.acdPlaceholder {
                    Text("NA days ago")
                        .italic()
                } else if entry.daysSinceWarfarin == 1 {
                    Text("\(entry.daysSinceWarfarin) day ago")
                        .italic()
                } else {
                    Text("\(entry.daysSinceWarfarin) days ago")
                        .italic()
                }
            }
            
            // INR Stack
            HStack() {
                Image(systemName: K.SFSymbols.inr)
                        .font(.system(size: 12))
                if entry.inrPlaceholder {
                    Text("NA")
                } else {
                    Text("\(entry.inrMeasurement[0].inr, specifier: "%.1f")")
                }
                
                if entry.inrPlaceholder {
                    Text("NA days ago")
                        .italic()
                } else if entry.daysSinceINR == 1 {
                    Text("\(entry.daysSinceINR) day ago")
                        .italic()
                } else {
                    Text("\(entry.daysSinceINR) days ago")
                        .italic()
                }
            }
        }
//        }
        .containerBackground(.clear, for: .widget)
    }
}
    
struct StatusAccessoryWidgetEntry: TimelineEntry {
    let date: Date
    let providerInfo: String
    let inrMeasurement: [INRMeasurement]
    let anticoagulantDose: [AntiCoagulantDose]
    let primaryAntiCoagulantName: String
    let inrPlaceholder: Bool
    let acdPlaceholder: Bool
    let daysSinceINR: Int
    let daysSinceWarfarin: Int
}

struct StatusAccessoryWidgetTimelineProvider: TimelineProvider {
    typealias Entry = StatusWidgetEntry
    let model = DataManager.shared
    @ObservedObject var prefs = Prefs.shared
    
    init() {
        print("Initialising StatusWidgetTimelineProvider")
    }
    
    func placeholder(in context: Context) -> Entry {
        return StatusWidgetEntry(
            date: Date(),
            providerInfo: "placeholder",
            inrMeasurement: [INRMeasurement](),
            anticoagulantDose: [AntiCoagulantDose](),
            primaryAntiCoagulantName: prefs.primaryAntiCoagulantName,
            inrPlaceholder: true,
            acdPlaceholder: true,
            daysSinceINR: 0,
            daysSinceWarfarin: 0
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (Entry) -> ()
    ) {
        print("getSnapshot INR Measurements: \(model.inrMeasurements)")
        var entry: StatusWidgetEntry
        var inrPlaceholder = false
        var acdPlaceholder = false
        let latestINR = model.mostRecentINRMeasurement()
        let latestACD = model.mostRecentAnticoagulantDose()
        
        if latestINR.count == 0 { inrPlaceholder = true }
        
        if latestACD.count == 0 { acdPlaceholder = true }
        
        entry = StatusWidgetEntry(
            date: Date(),
            providerInfo: "snapshot",
            inrMeasurement: model.mostRecentINRMeasurement(),
            anticoagulantDose: model.mostRecentAnticoagulantDose(),
            primaryAntiCoagulantName: prefs.primaryAntiCoagulantName,
            inrPlaceholder: inrPlaceholder,
            acdPlaceholder: acdPlaceholder,
            daysSinceINR: 0,
            daysSinceWarfarin: 0
        )
        
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        print("getSnapshot INR Measurements: \(model.inrMeasurements)")
        var entry: StatusWidgetEntry
        var inrPlaceholder = false
        var acdPlaceholder = false
        let latestINR = model.mostRecentINRMeasurement()
        let latestACD = model.mostRecentAnticoagulantDose()
        var daysSinceINR = 0
        var daysSinceACD = 0
        
        if latestINR.count == 0 { inrPlaceholder = true }
        if latestACD.count == 0 { acdPlaceholder = true }
        
        if !inrPlaceholder { daysSinceINR = Calendar.current.numberOfDaysBetween(latestINR[0].timestamp ?? Date(), and: Date()) }
        if !acdPlaceholder { daysSinceACD = Calendar.current.numberOfDaysBetween(latestACD[0].timestamp ?? Date(), and: Date()) }
        
        entry = StatusWidgetEntry(
            date: Date(),
            providerInfo: "timeline",
            inrMeasurement: model.mostRecentINRMeasurement(),
            anticoagulantDose: model.mostRecentAnticoagulantDose(),
            primaryAntiCoagulantName: prefs.primaryAntiCoagulantName,
            inrPlaceholder: inrPlaceholder,
            acdPlaceholder: acdPlaceholder,
            daysSinceINR: daysSinceINR,
            daysSinceWarfarin: daysSinceACD
        )
        
        let date = Calendar.current.date(byAdding: .minute, value: 360, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(date))
        completion(timeline)
    }
}

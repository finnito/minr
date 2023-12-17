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
import os

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
    let entry: StatusAccessoryWidgetEntry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
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
                
//                Spacer()
                
                HStack {
                    if entry.acdPlaceholder {
                        Text("NA days ago")
                            .italic()
                    } else {
                        switch entry.daysSinceWarfarin {
                        case 0:
                            Text("today")
                        case 1:
                            Text("\(entry.daysSinceWarfarin) day ago")
                        default:
                            Text("\(entry.daysSinceWarfarin) days ago")
                        }
                    }
                }
                .font(.caption2)
                .italic()
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
                
//                Spacer()
                
                HStack {
                    if entry.inrPlaceholder {
                        Text("NA days ago")
                            .italic()
                    } else {
                        switch entry.daysSinceINR {
                        case 0:
                            Text("today")
                        case 1:
                            Text("\(entry.daysSinceINR) day ago")
                        default:
                            Text("\(entry.daysSinceINR) days ago")
                        }
                    }
                }
                .font(.caption2)
                .italic()
            }
            Spacer()
        }
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
    typealias Entry = StatusAccessoryWidgetEntry
    @ObservedObject var dataModel = DataManager.shared
    @ObservedObject var prefs = Prefs.shared
    
    init() {
        Logger().info("Widget_Status-accessory: init()")
    }
    
    func placeholder(in context: Context) -> Entry {
        Logger().info("Widget_Status-accessory: placeholder()")
        let latestINREntry = dataModel.mostRecentINRMeasurement()
        let latestACDEntry = dataModel.mostRecentAnticoagulantDose()
        
        var daysSinceINR: Int
        if latestINREntry.count != 1 {
            daysSinceINR = 7
        }
        daysSinceINR = Calendar.current.numberOfDaysBetween(latestINREntry[0].timestamp ?? Date(), and: Date())
        
        var daysSinceACD: Int
        if latestACDEntry.count != 1 {
            daysSinceACD = 7
        }
        daysSinceACD = Calendar.current.numberOfDaysBetween(latestACDEntry[0].timestamp ?? Date(), and: Date())
        
        return StatusAccessoryWidgetEntry(
            date: Date(),
            providerInfo: "placeholder",
            inrMeasurement: latestINREntry,
            anticoagulantDose: latestACDEntry,
            primaryAntiCoagulantName: prefs.primaryAntiCoagulantName,
            inrPlaceholder: false,
            acdPlaceholder: false,
            daysSinceINR: daysSinceINR,
            daysSinceWarfarin: daysSinceACD
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (Entry) -> ()
    ) {
        Logger().info("Widget_Status-accessory: getSnapshot()")
        
        let latestINREntry = dataModel.mostRecentINRMeasurement()
        let latestACDEntry = dataModel.mostRecentAnticoagulantDose()
        
        var daysSinceINR: Int
        if latestINREntry.count != 1 {
            daysSinceINR = 7
        }
        daysSinceINR = Calendar.current.numberOfDaysBetween(latestINREntry[0].timestamp ?? Date(), and: Date())
        
        var daysSinceACD: Int
        if latestACDEntry.count != 1 {
            daysSinceACD = 7
        }
        daysSinceACD = Calendar.current.numberOfDaysBetween(latestACDEntry[0].timestamp ?? Date(), and: Date())
        
        let entry = StatusAccessoryWidgetEntry(
            date: Date(),
            providerInfo: "snapshot",
            inrMeasurement: latestINREntry,
            anticoagulantDose: latestACDEntry,
            primaryAntiCoagulantName: prefs.primaryAntiCoagulantName,
            inrPlaceholder: false,
            acdPlaceholder: false,
            daysSinceINR: daysSinceINR,
            daysSinceWarfarin: daysSinceACD
        )
        
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        Logger().info("Widget_Status-accessory: getTimeline()")
        var entry: StatusAccessoryWidgetEntry
        var inrPlaceholder = false
        var acdPlaceholder = false
        let latestINR = dataModel.mostRecentINRMeasurement()
        let latestACD = dataModel.mostRecentAnticoagulantDose()
        var daysSinceINR = 0
        var daysSinceACD = 0
        
        if latestINR.count == 0 { inrPlaceholder = true }
        if latestACD.count == 0 { acdPlaceholder = true }
        
        if !inrPlaceholder { daysSinceINR = Calendar.current.numberOfDaysBetween(latestINR[0].timestamp ?? Date(), and: Date()) }
        if !acdPlaceholder { daysSinceACD = Calendar.current.numberOfDaysBetween(latestACD[0].timestamp ?? Date(), and: Date()) }
        
        entry = StatusAccessoryWidgetEntry(
            date: Date(),
            providerInfo: "timeline",
            inrMeasurement: dataModel.mostRecentINRMeasurement(),
            anticoagulantDose: dataModel.mostRecentAnticoagulantDose(),
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

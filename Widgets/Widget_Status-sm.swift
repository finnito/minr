//
//  WidgetChart.swift
//  Widgets
//
//  Created by Finn LeSueur on 3/04/23.
//

import ActivityKit
import WidgetKit
import SwiftUI
import Intents
import Charts
import os

struct WidgetStatus: Widget {
    let kind: String = "com.minr.widget_status"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StatusWidgetTimelineProvider()
        ) { entry in
            StatusWidgetView(entry: entry)
        }
        .configurationDisplayName("Status Widget")
        .description("Display your anticoagulant and INR status at a glance.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct StatusWidgetView: View {
    let entry: StatusWidgetEntry
    var body: some View {
        GeometryReader { metrics in
            VStack(spacing: 0) {
                // INR Stack
                HStack(alignment: .firstTextBaseline) {
                    VStack {
                        if entry.inrPlaceholder {
                            Text("NA")
                        } else {
                            Text("\(entry.inrMeasurement[0].inr, specifier: "%.1f")")
                        }
                    }
                    .font(.title2)
                    .fontWeight(.heavy)
                    .padding(.leading, 5)
                                        
                    if entry.inrPlaceholder {
                        Text("NA days ago")
                            .font(.caption2)
                            .italic()
                    } else if entry.daysSinceINR == 1 {
                        Text("\(entry.daysSinceINR) day ago")
                            .font(.caption2)
                            .italic()
                    } else {
                        Text("\(entry.daysSinceINR) days ago")
                            .font(.caption2)
                            .italic()
                    }
                }
                .padding(.bottom, 10)
                .frame(width: metrics.size.width, height: metrics.size.height * 0.5)
                .overlay(alignment: .bottomLeading) {
                    Text("\(Image(systemName: K.SFSymbols.inr)) INR")
                        .font(.system(.caption, design: .monospaced).smallCaps())
                        .padding(.horizontal, 7)
                        .padding(.vertical, 5)
                        .opacity(0.75)
                }
                
                // Warfarin Stack
                HStack(alignment: .firstTextBaseline) {
                    VStack {
                        if entry.acdPlaceholder {
                            Text("NA")
                        } else {
                            Text("\(entry.anticoagulantDose[0].dose)mg")
                        }
                    }
                    .font(.title2)
                    .fontWeight(.heavy)
                    .padding(.leading, 5)
                                        
                    if entry.acdPlaceholder {
                        Text("NA days ago")
                            .font(.caption2)
                            .italic()
                    } else if entry.daysSinceWarfarin == 1 {
                        Text("\(entry.daysSinceWarfarin) day ago")
                            .font(.caption2)
                            .italic()
                    } else {
                        Text("\(entry.daysSinceWarfarin) days ago")
                            .font(.caption2)
                            .italic()
                    }
                }
                .padding(.top, 10)
                .frame(width: metrics.size.width, height: metrics.size.height * 0.5)                
                .overlay(alignment: .topTrailing) {
                    Text("\(entry.prefs.primaryAntiCoagulantName) \(Image(systemName: K.SFSymbols.anticoagulant))")
                        .font(.system(.caption, design: .monospaced).smallCaps())
                        .padding(.horizontal, 7)
                        .padding(.vertical, 5)
                        .opacity(0.75)
                }
                
            }
        }
        .containerBackground(for: .widget) {
            VStack(spacing: 0) {
                entry.prefs.chartINRColor.opacity(0.4)
                entry.prefs.chartAnticoagulantColor.opacity(0.4)
            }
        }
    }
}
    
struct StatusWidgetEntry: TimelineEntry {
    let date: Date
    let providerInfo: String
    let prefs: Prefs
    let inrMeasurement: [INRMeasurement]
    let anticoagulantDose: [AntiCoagulantDose]
    let inrPlaceholder: Bool
    let acdPlaceholder: Bool
    let daysSinceINR: Int
    let daysSinceWarfarin: Int
}

struct StatusWidgetTimelineProvider: TimelineProvider {
    typealias Entry = StatusWidgetEntry
    @ObservedObject var dataModel = DataManager.shared
    @ObservedObject var prefs = Prefs.shared
    
    init() {
        Logger().info("Widget_Status-sm: init()")
    }
    
    func placeholder(in context: Context) -> Entry {
        Logger().info("Widget_Status-sm: placeholder()")
        return StatusWidgetEntry(
            date: Date(),
            providerInfo: "placeholder",
            prefs: prefs,
            inrMeasurement: [INRMeasurement](),
            anticoagulantDose: [AntiCoagulantDose](),
            inrPlaceholder: true,
            acdPlaceholder: true,
            daysSinceINR: 7,
            daysSinceWarfarin: 7
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (Entry) -> ()
    ) {
        Logger().info("Widget_Status-sm: getSnapshot()")
        var entry: StatusWidgetEntry
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
        
        entry = StatusWidgetEntry(
            date: Date(),
            providerInfo: "snapshot",
            prefs: prefs,
            inrMeasurement: dataModel.mostRecentINRMeasurement(),
            anticoagulantDose: dataModel.mostRecentAnticoagulantDose(),
            inrPlaceholder: inrPlaceholder,
            acdPlaceholder: acdPlaceholder,
            daysSinceINR: daysSinceINR,
            daysSinceWarfarin: daysSinceACD
        )
        
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        Logger().info("Widget_Status-sm: getTimeline()")
        var entry: StatusWidgetEntry
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
        
        entry = StatusWidgetEntry(
            date: Date(),
            providerInfo: "timeline",
            prefs: prefs,
            inrMeasurement: dataModel.mostRecentINRMeasurement(),
            anticoagulantDose: dataModel.mostRecentAnticoagulantDose(),
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

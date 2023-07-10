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

struct WidgetStatus: Widget {
    let kind: String = "com.minr.widget_status"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StatusWidgetTimelineProvider()
        ) { entry in
            StatusWidgetView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
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
                    .font(.title)
                    .fontWeight(.heavy)
                    .padding(.leading, 5)
                    
                    if entry.inrPlaceholder {
                        Text("NA days ago")
                            .font(.footnote)
                            .italic()
                    } else if entry.daysSinceINR == 1 {
                        Text("\(entry.daysSinceINR) day ago")
                            .font(.footnote)
                            .italic()
                    } else {
                        Text("\(entry.daysSinceINR) days ago")
                            .font(.footnote)
                            .italic()
                    }
                }
                .padding(.bottom, 10)
                .frame(width: metrics.size.width, height: metrics.size.height * 0.5)
                .background(.blue.opacity(0.4))
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
                    .font(entry.anticoagulantDose[0].dose < 10 ? .title : .title2)
                    .fontWeight(.heavy)
                    .padding(.leading, 5)
                    
                    if entry.acdPlaceholder {
                        Text("NA days ago")
                            .font(.footnote)
                            .italic()
                    } else if entry.daysSinceWarfarin == 1 {
                        Text("\(entry.daysSinceWarfarin) day ago")
                            .font(.footnote)
                            .italic()
                    } else {
                        Text("\(entry.daysSinceWarfarin) days ago")
                            .font(.footnote)
                            .italic()
                    }
                }
                .padding(.top, 10)
                .frame(width: metrics.size.width, height: metrics.size.height * 0.5)                
                .background(.red.opacity(0.4))
                .overlay(alignment: .topTrailing) {
                    Text("\(entry.primaryAntiCoagulantName) \(Image(systemName: K.SFSymbols.anticoagulant))")
                        .font(.system(.caption, design: .monospaced).smallCaps())
                        .padding(.horizontal, 7)
                        .padding(.vertical, 5)
                        .opacity(0.75)
                }
                
            }
        }
    }
}
    
struct StatusWidgetEntry: TimelineEntry {
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

struct StatusWidgetTimelineProvider: TimelineProvider {
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
        var daysSinceINR = 0
        var daysSinceACD = 0
        
        if latestINR.count == 0 { inrPlaceholder = true }
        if latestACD.count == 0 { acdPlaceholder = true }
        
        if !inrPlaceholder { daysSinceINR = Calendar.current.numberOfDaysBetween(latestINR[0].timestamp ?? Date(), and: Date()) }
        if !acdPlaceholder { daysSinceACD = Calendar.current.numberOfDaysBetween(latestACD[0].timestamp ?? Date(), and: Date()) }
        
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

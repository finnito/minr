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

struct WidgetChart: Widget {
    let kind: String = "com.minr.widget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ChartRangeConfigurationIntent.self,
            provider: ChartWidgetTimelineProvider()
        ) { entry in
            ChartWidgetView(entry: entry)
        }
        .configurationDisplayName("Chart Configuration")
        .description("The maximum number of days to display.")
        .supportedFamilies([.systemMedium])
    }
}

struct ChartWidgetView: View {
    @AppStorage("maximumINRRange") var maximumINR: Double = 3.5
    @AppStorage("minimumINRRange") var minimumINR: Double = 2.5
    @AppStorage("primaryAntiCoagulantName") var primaryAntiCoagulantName: String = "Warfarin"
    let entry: ChartWidgetEntry
    var body: some View {
        Chart {
            RectangleMark(
                xStart: nil,
                xEnd: nil,
                yStart: .value("Maximum", maximumINR),
                yEnd: .value("Minimum", minimumINR)
            )
            .foregroundStyle(.green.opacity(0.25))
            
            ForEach(entry.inrMeasurements) { item in
                LineMark(
                    x: .value("Date", item.timestamp ?? Date()),
                    y: .value("INR", item.inr),
                    series: .value("Measurement", "INR")
                )
                .foregroundStyle(.red)
                .interpolationMethod(.linear)
                .symbol(Circle())
            }
            
            ForEach(entry.anticoagulantDoses) { item in
                LineMark(
                    x: .value("Date", item.timestamp ?? Date()),
                    y: .value("\(primaryAntiCoagulantName)", item.dose),
                    series: .value("Measurement", "\(primaryAntiCoagulantName)")
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.linear)
                .symbol(Circle())
            }
        }
        .padding(.horizontal, 5)
        .padding(.top, 15)
        .padding(.bottom, 5)
        .chartLegend(position: .overlay, alignment: .topLeading, spacing: 10)
        .chartForegroundStyleScale([
            "INR": Color.red,
            "\(primaryAntiCoagulantName)": Color.blue,
            "INR Range": Color.green
        ])
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: entry.chartRange < 10 ? entry.chartRange : 10
                                        )) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
    }
}

struct ChartWidgetEntry: TimelineEntry {
    let date: Date
    let providerInfo: String
    let chartRange: Int
    let inrMeasurements: [INRMeasurement]
    let anticoagulantDoses: [AntiCoagulantDose]
}

struct ChartWidgetTimelineProvider: IntentTimelineProvider {    
    typealias Intent = ChartRangeConfigurationIntent
    typealias Entry = ChartWidgetEntry
    let model = DataManager.shared
    init() {
        print("Initialising ChartWidgetTimelineProvider")
        
    }
    
    func placeholder(in context: Context) -> Entry {
        return ChartWidgetEntry(
            date: Date(),
            providerInfo: "placeholder",
            chartRange: 14,
            inrMeasurements: [],
            anticoagulantDoses: []
        )
    }

    func getSnapshot(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Entry) -> ()
    ) {
        print("getSnapshot INR Measurements: \(model.inrMeasurements)")
        let entry = ChartWidgetEntry(
            date: Date(),
            providerInfo: "snapshot",
            chartRange: configuration.ChartRange as! Int,
            inrMeasurements: [],
            anticoagulantDoses: []
        )
        completion(entry)
    }

    func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        print("getTimeline INR Measurements: \(model.inrMeasurements)")
        let now = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: configuration.ChartRange as! Int * -1, to: now) ?? Date.now
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? Date.now
        let inrMeasurements = model.getINRMeasurementsBetween(start: startDate, end: endDate)
        let antiCoagulantDoses = model.getAntiCoagulantDosesBetween(start: startDate, end: endDate)
        
        let entry = ChartWidgetEntry(
            date: Date(),
            providerInfo: "timeline",
            chartRange: configuration.ChartRange as! Int,
            inrMeasurements: inrMeasurements,
            anticoagulantDoses: antiCoagulantDoses
        )
        let date = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(date))
        completion(timeline)
    }
}

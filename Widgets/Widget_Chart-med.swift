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
        .configurationDisplayName("Chart")
        .description("Display your anticoagulantion doses and INR on a chart.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

struct ChartWidgetView: View {
    let entry: ChartWidgetEntry
    
    var body: some View {
        Chart {
            RectangleMark(
                xStart: nil,
                xEnd: nil,
                yStart: .value("Maximum", entry.maximumINR),
                yEnd: .value("Minimum", entry.minimumINR)
            )
            .foregroundStyle(.green.opacity(0.25))
            
            ForEach(entry.inrMeasurements) { item in
                LineMark(
                    x: .value("Date", item.timestamp ?? Date()),
                    y: .value("INR", item.inr),
                    series: .value("Measurement", "INR")
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.linear)
                .symbol(Circle())
                
                if entry.showINRLabels {
                    PointMark(
                        x: .value("Date", item.timestamp ?? Date()),
                        y: .value("INR", item.inr)
                    )
                    .opacity(0)
                    .annotation(position: .overlay, alignment: .topTrailing, spacing: 10) {
                        Text("\(item.inr, specifier: "%.1f")").font(.footnote)
                    }
                }
            }
            
            ForEach(entry.anticoagulantDoses) { item in
                LineMark(
                    x: .value("Date", item.timestamp ?? Date()),
                    y: .value("\(entry.primaryAntiCoagulantName)", item.dose),
                    series: .value("Measurement", "\(entry.primaryAntiCoagulantName)")
                )
                    .foregroundStyle(.red)
                .interpolationMethod(.linear)
                .symbol(Circle())
                
                if entry.showAnticoagulantLabels {
                    PointMark(
                        x: .value("Date", item.timestamp ?? Date()),
                        y: .value("\(entry.primaryAntiCoagulantName)", item.dose)
                    )
                    .opacity(0)
                    .annotation(position: .overlay, alignment: .topTrailing, spacing: 10) {
                        Text("\(item.dose)mg").font(.footnote)
                    }
                }
                
                if (entry.secondaryAntiCoagulantEnabled) {
                    LineMark(
                        x: .value("Date", item.timestamp ?? Date()),
                        y: .value("\(entry.secondaryAntiCoagulantName)", item.secondaryDose),
                        series: .value("Measurement2", "\(entry.secondaryAntiCoagulantName)")
                    )
                    .foregroundStyle(.purple)
                    .interpolationMethod(.linear)
                    .symbol(Circle())
                    
                    if entry.showAnticoagulantLabels {
                        PointMark(
                            x: .value("Date", item.timestamp ?? Date()),
                            y: .value("\(entry.secondaryAntiCoagulantName)", item.secondaryDose)
                        )
                        .opacity(0)
                        .annotation(position: .overlay, alignment: .topTrailing, spacing: 10) {
                            Text("\(item.secondaryDose)mg").font(.footnote)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 5)
        .padding(.top, 15)
        .padding(.bottom, 5)
        .chartLegend(position: .overlay, alignment: .topLeading, spacing: 10)
        .chartForegroundStyleScale(entry.legend)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .containerBackground(colorScheme == .dark ? K.Colours.cardBackgroundDark : K.Colours.cardBackgroundLight, for: .widget)
    }
}

struct ChartWidgetEntry: TimelineEntry {
    let date: Date
    let providerInfo: String
    let maximumINR: Double
    let minimumINR: Double
    let primaryAntiCoagulantName: String
    let secondaryAntiCoagulantName: String
    let secondaryAntiCoagulantEnabled: Bool
    let chartRange: Int
    let inrMeasurements: [INRMeasurement]
    let anticoagulantDoses: [AntiCoagulantDose]
    let showINRLabels: Bool
    let showAnticoagulantLabels: Bool
    let legend: KeyValuePairs<String,Color>
}

struct ChartWidgetTimelineProvider: IntentTimelineProvider {
    @ObservedObject var prefs = Prefs.shared
    
    typealias Intent = ChartRangeConfigurationIntent
    typealias Entry = ChartWidgetEntry
    let model = DataManager.shared
    
    init() {
        print("Initialising ChartWidgetTimelineProvider")
    }
    
    func placeholder(in context: Context) -> Entry {
        
        var legend: KeyValuePairs<String,Color>
        if prefs.secondaryAntiCoagulantEnabled {
            legend = [
                "INR": Color.blue,
                "\(prefs.primaryAntiCoagulantName)": Color.red,
                "\(prefs.secondaryAntiCoagulantName)": Color.purple,
                "INR Range": Color.green
            ]
        } else {
            legend = [
                "INR": Color.blue,
                "\(prefs.primaryAntiCoagulantName)": Color.red,
                "INR Range": Color.green
            ]
        }
        
        return ChartWidgetEntry(
            date: Date(),
            providerInfo: "placeholder",
            maximumINR: prefs.maximumINR,
            minimumINR: prefs.minimumINR,
            primaryAntiCoagulantName: prefs.primaryAntiCoagulantName,
            secondaryAntiCoagulantName: prefs.secondaryAntiCoagulantName,
            secondaryAntiCoagulantEnabled: prefs.secondaryAntiCoagulantEnabled,
            chartRange: 14,
            inrMeasurements: [],
            anticoagulantDoses: [],
            showINRLabels: false,
            showAnticoagulantLabels: false,
            legend: legend
        )
    }

    func getSnapshot(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Entry) -> ()
    ) {
        print("getSnapshot INR Measurements: \(model.inrMeasurements)")
        
        var legend: KeyValuePairs<String,Color>
        if prefs.secondaryAntiCoagulantEnabled {
            legend = [
                "INR": Color.blue,
                "\(prefs.primaryAntiCoagulantName)": Color.red,
                "\(prefs.secondaryAntiCoagulantName)": Color.purple,
                "INR Range": Color.green
            ]
        } else {
            legend = [
                "INR": Color.blue,
                "\(prefs.primaryAntiCoagulantName)": Color.red,
                "INR Range": Color.green
            ]
        }
        
        let entry = ChartWidgetEntry(
            date: Date(),
            providerInfo: "snapshot",
            maximumINR: prefs.maximumINR,
            minimumINR: prefs.minimumINR,
            primaryAntiCoagulantName: prefs.primaryAntiCoagulantName,
            secondaryAntiCoagulantName: prefs.secondaryAntiCoagulantName,
            secondaryAntiCoagulantEnabled: prefs.secondaryAntiCoagulantEnabled,
            chartRange: configuration.ChartRange as! Int,
            inrMeasurements: [],
            anticoagulantDoses: [],
            showINRLabels: configuration.ShowINRLabels?.boolValue ?? false,
            showAnticoagulantLabels: configuration.ShowAnticoagulantLabels?.boolValue ?? false,
            legend: legend
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
        
        var legend: KeyValuePairs<String,Color>
        if prefs.secondaryAntiCoagulantEnabled {
            legend = [
                "INR": Color.blue,
                "\(prefs.primaryAntiCoagulantName)": Color.red,
                "\(prefs.secondaryAntiCoagulantName)": Color.purple,
                "INR Range": Color.green
            ]
        } else {
            legend = [
                "INR": Color.blue,
                "\(prefs.primaryAntiCoagulantName)": Color.red,
                "INR Range": Color.green
            ]
        }
        
        let entry = ChartWidgetEntry(
            date: Date(),
            providerInfo: "timeline",
            maximumINR: prefs.maximumINR,
            minimumINR: prefs.minimumINR,
            primaryAntiCoagulantName: prefs.primaryAntiCoagulantName,
            secondaryAntiCoagulantName: prefs.secondaryAntiCoagulantName,
            secondaryAntiCoagulantEnabled: prefs.secondaryAntiCoagulantEnabled,
            chartRange: configuration.ChartRange as! Int,
            inrMeasurements: inrMeasurements,
            anticoagulantDoses: antiCoagulantDoses,
            showINRLabels: configuration.ShowINRLabels?.boolValue ?? false,
            showAnticoagulantLabels: configuration.ShowAnticoagulantLabels?.boolValue ?? false,
            legend: legend
        )
        let date = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(date))
        completion(timeline)
    }
}

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
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var dataModel = DataManager.shared
    
    private var inrMeasurements: [INRMeasurement] = []
    private var antiCoagulantDoses: [AntiCoagulantDose] = []
    
    private var yAxisMaximum: Double = 0.0
    private var inrAxisMaximum: Double = 0.0
    private var anticoagulantAxisMaximum: Int = 0
    
    private var endDate: Date = Date.now
    private var startDate: Date = Date.now
    
    private var maxINRInRange: Double = 0.0
    private var maxDoseInRange: Int = 0
    private var maxSecondaryDoseInRange: Int = 0
    
    init (entry: ChartWidgetEntry) {
        self.entry = entry
        let now = Date.now
        self.startDate = Calendar.current.date(byAdding: .day, value: entry.chartRange * -1, to: now) ?? Date.now
        self.endDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? Date.now
        self.inrMeasurements = dataModel.getINRMeasurementsBetween(start: startDate, end: endDate)
        self.antiCoagulantDoses = dataModel.getAntiCoagulantDosesBetween(start: startDate, end: endDate)
        let maxAntiCoagulantDose = dataModel.highestAntiCoagulantDoseInRange(start: startDate, end: endDate)
        let maxINRMeasurement = dataModel.highestINRInRange(start: startDate, end: endDate)
        
        if (maxINRMeasurement.count > 0) {
            self.maxINRInRange = maxINRMeasurement[0].inr
            self.inrAxisMaximum = (maxINRMeasurement[0].inr + 1.0).rounded(.up)
        } else {
            self.inrAxisMaximum = 5
        }
        
        if (maxAntiCoagulantDose.count > 0) {
            if maxAntiCoagulantDose[0].dose.isMultiple(of: 2) {
                self.anticoagulantAxisMaximum = Int(maxAntiCoagulantDose[0].dose) + 2
            } else {
                self.anticoagulantAxisMaximum = Int(maxAntiCoagulantDose[0].dose) + 3
            }
        } else {
            self.anticoagulantAxisMaximum = 6
        }
    }
    
    var body: some View {
        Chart {
            RectangleMark(
                xStart: nil,
                xEnd: nil,
                yStart: .value("Maximum", entry.prefs.maximumINR / self.inrAxisMaximum),
                yEnd: .value("Minimum", entry.prefs.minimumINR / self.inrAxisMaximum)
            )
            .foregroundStyle(entry.prefs.chartINRRangeColor)
            
            ForEach(entry.inrMeasurements) { item in
                LineMark(
                    x: .value("Date", item.timestamp ?? Date()),
                    y: .value("INR", item.inr / inrAxisMaximum),
                    series: .value("Measurement", "INR")
                )
                .foregroundStyle(entry.prefs.chartINRColor)
                .interpolationMethod(.linear)
                .symbol(Circle())
                
                if entry.showINRLabels {
                    PointMark(
                        x: .value("Date", item.timestamp ?? Date()),
                        y: .value("INR", item.inr / inrAxisMaximum)
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
                    y: .value("\(entry.prefs.primaryAntiCoagulantName)", Double(item.dose) / Double(self.anticoagulantAxisMaximum)),
                    series: .value("Measurement", "\(entry.prefs.primaryAntiCoagulantName)")
                )
                .foregroundStyle(entry.prefs.chartAnticoagulantColor)
                .interpolationMethod(.linear)
                .symbol(Circle())
                
                if entry.showAnticoagulantLabels {
                    PointMark(
                        x: .value("Date", item.timestamp ?? Date()),
                        y: .value("\(entry.prefs.primaryAntiCoagulantName)", Double(item.dose) / Double(self.anticoagulantAxisMaximum))
                    )
                    .opacity(0)
                    .annotation(position: .overlay, alignment: .topTrailing, spacing: 10) {
                        Text("\(item.dose)mg").font(.footnote)
                    }
                }
                
//                if (entry.prefs.secondaryAntiCoagulantEnabled) {
//                    LineMark(
//                        x: .value("Date", item.timestamp ?? Date()),
//                        y: .value("\(entry.prefs.secondaryAntiCoagulantName)", item.secondaryDose),
//                        series: .value("Measurement2", "\(entry.prefs.secondaryAntiCoagulantName)")
//                    )
//                    .foregroundStyle(entry.prefs.chartSecondaryAnticoagulantColor)
//                    .interpolationMethod(.linear)
//                    .symbol(Circle())
//                    
//                    if entry.showAnticoagulantLabels {
//                        PointMark(
//                            x: .value("Date", item.timestamp ?? Date()),
//                            y: .value("\(entry.prefs.secondaryAntiCoagulantName)", item.secondaryDose)
//                        )
//                        .opacity(0)
//                        .annotation(position: .overlay, alignment: .topTrailing, spacing: 10) {
//                            Text("\(item.secondaryDose)mg").font(.footnote)
//                        }
//                    }
//                }
            }
        }
        .padding(.horizontal, 5)
        .padding(.top, 15)
        .padding(.bottom, 5)
        .chartLegend(position: .automatic, alignment: .topLeading, spacing: 10)
        .chartForegroundStyleScale(entry.legend)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            let steps = 5.0
            let normalisedStride = Array(stride(from: 0, to: 1, by: 1.0/steps))
            AxisMarks(position: .leading, values: normalisedStride) { mark in
                AxisGridLine()
            }
        }
        .containerBackground(colorScheme == .dark ? K.Colours.cardBackgroundDark : K.Colours.cardBackgroundLight, for: .widget)
    }
}

struct ChartWidgetEntry: TimelineEntry {
    let date: Date
    let providerInfo: String
    let prefs: Prefs
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
    @ObservedObject var dataModel = DataManager.shared
    
    init() {
        Logger().info("Widget_Chart-med: init()")
    }
    
    func placeholder(in context: Context) -> Entry {
        Logger().info("Widget_Chart-med: placeholder() called.")
        let now = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: -14, to: now) ?? Date.now
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? Date.now
        
        var legend: KeyValuePairs<String,Color>
        if prefs.secondaryAntiCoagulantEnabled {
            legend = [
                "INR": prefs.chartINRColor,
                "\(prefs.primaryAntiCoagulantName)": prefs.chartAnticoagulantColor,
                "\(prefs.secondaryAntiCoagulantName)": prefs.chartSecondaryAnticoagulantColor,
                "INR Range": prefs.chartINRRangeColor
            ]
        } else {
            legend = [
                "INR": prefs.chartINRColor,
                "\(prefs.primaryAntiCoagulantName)": prefs.chartAnticoagulantColor,
                "INR Range": prefs.chartINRRangeColor
            ]
        }
        
        return ChartWidgetEntry(
            date: Date(),
            providerInfo: "placeholder",
            prefs: prefs,
            chartRange: 14,
            inrMeasurements: dataModel.getINRMeasurementsBetween(start: startDate, end: endDate),
            anticoagulantDoses: dataModel.getAntiCoagulantDosesBetween(start: startDate, end: endDate),
            showINRLabels: true,
            showAnticoagulantLabels: false,
            legend: legend
        )
    }

    func getSnapshot(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Entry) -> ()
    ) {
        Logger().info("Widget_Chart-med: getSnapshot() called.")
        
        let now = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: -14, to: now) ?? Date.now
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? Date.now
        let inrMeasurements = dataModel.getINRMeasurementsBetween(start: startDate, end: endDate)
        let antiCoagulantDoses = dataModel.getAntiCoagulantDosesBetween(start: startDate, end: endDate)
        
        var legend: KeyValuePairs<String,Color>
        if prefs.secondaryAntiCoagulantEnabled {
            legend = [
                "INR": prefs.chartINRColor,
                "\(prefs.primaryAntiCoagulantName)": prefs.chartAnticoagulantColor,
                "\(prefs.secondaryAntiCoagulantName)": prefs.chartSecondaryAnticoagulantColor,
                "INR Range": prefs.chartINRRangeColor
            ]
        } else {
            legend = [
                "INR": prefs.chartINRColor,
                "\(prefs.primaryAntiCoagulantName)": prefs.chartAnticoagulantColor,
                "INR Range": prefs.chartINRRangeColor
            ]
        }
        
        let entry = ChartWidgetEntry(
            date: Date(),
            providerInfo: "snapshot",
            prefs: prefs,
            chartRange: configuration.ChartRange as! Int,
            inrMeasurements: inrMeasurements,
            anticoagulantDoses: antiCoagulantDoses,
            showINRLabels: true,
            showAnticoagulantLabels: false,
            legend: legend
        )
        completion(entry)
    }

    func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        Logger().info("Widget_Chart-med: getTimeline() called.")
        let now = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: configuration.ChartRange as! Int * -1, to: now) ?? Date.now
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? Date.now
        let inrMeasurements = dataModel.getINRMeasurementsBetween(start: startDate, end: endDate)
        let antiCoagulantDoses = dataModel.getAntiCoagulantDosesBetween(start: startDate, end: endDate)
        
        var legend: KeyValuePairs<String,Color>
        if prefs.secondaryAntiCoagulantEnabled {
            legend = [
                "INR": prefs.chartINRColor,
                "\(prefs.primaryAntiCoagulantName)": prefs.chartAnticoagulantColor,
                "\(prefs.secondaryAntiCoagulantName)": prefs.chartSecondaryAnticoagulantColor,
                "INR Range": prefs.chartINRRangeColor
            ]
        } else {
            legend = [
                "INR": prefs.chartINRColor,
                "\(prefs.primaryAntiCoagulantName)": prefs.chartAnticoagulantColor,
                "INR Range": prefs.chartINRRangeColor
            ]
        }
        
        let entry = ChartWidgetEntry(
            date: Date(),
            providerInfo: "timeline",
            prefs: prefs,
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

struct ChartWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        let now = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: 14, to: now) ?? Date.now
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? Date.now
        let inrMeasurements = DataManager.shared.getINRMeasurementsBetween(start: startDate, end: endDate)
        let antiCoagulantDoses = DataManager.shared.getAntiCoagulantDosesBetween(start: startDate, end: endDate)
        
        var legend: KeyValuePairs<String,Color> = [
            "INR": Prefs.shared.chartINRColor,
            "\(Prefs.shared.primaryAntiCoagulantName)": Prefs.shared.chartAnticoagulantColor,
            "INR Range": Prefs.shared.chartINRRangeColor
        ]
        
        let entry = ChartWidgetEntry(
            date: Date(),
            providerInfo: "timeline",
            prefs: Prefs.shared,
            chartRange: 14,
            inrMeasurements: inrMeasurements,
            anticoagulantDoses: antiCoagulantDoses,
            showINRLabels: true,
            showAnticoagulantLabels: true,
            legend: legend
        )
        
        ChartWidgetView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

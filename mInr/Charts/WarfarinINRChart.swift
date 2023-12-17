//
//  WarfarinINRChart.swift
//  mInr
//
//  Created by Finn LeSueur on 18/02/23.
//

import SwiftUI
import Charts
import CoreData
import os

struct WarfarinINRChart: View {
    @ObservedObject var dataModel = DataManager.shared
    @ObservedObject var prefs = Prefs.shared
    
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
    
    init () {
        let now = Date.now
        self.startDate = Calendar.current.date(byAdding: .day, value: prefs.graphRange * -1, to: now) ?? Date.now
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
    
    // Form the view
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                Chart {
                    // Section: INR Range
                    RectangleMark(
                        xStart: nil,
                        xEnd: nil,
                        yStart: .value("Maximum", prefs.maximumINR / self.inrAxisMaximum),
                        yEnd: .value("Minimum", prefs.minimumINR / self.inrAxisMaximum)
                    )
                    .foregroundStyle(prefs.chartINRRangeColor)
                    
                    // Section: INR Measurements
                    ForEach(inrMeasurements) { item in
                        LineMark(
                            x: .value("Date", item.timestamp ?? endDate),
                            y: .value("INR", item.inr / inrAxisMaximum),
                            series: .value("Measurement", "INR")
                        )
                        .foregroundStyle(prefs.chartINRColor)
                        .interpolationMethod(.linear)
                        .symbol(Circle())
                        
                        PointMark(
                            x: .value("Date", item.timestamp ?? endDate),
                            y: .value("INR", item.inr / inrAxisMaximum)
                        )
                        .opacity(0)
                        .annotation(position: .overlay, alignment: .topTrailing, spacing: 10) {
                            Text("\(item.inr, specifier: "%.1f")").font(.footnote)
                        }
                    }
                    
                    // SECTION: Anticoagulant Doses
                    ForEach(antiCoagulantDoses) { item in
                        LineMark(
                            x: .value("Date",
                                      item.timestamp ?? endDate),
                            y: .value("\(prefs.primaryAntiCoagulantName)",
                                      Double(item.dose) / Double(self.anticoagulantAxisMaximum)),
                            series: .value("Anticoagulant", "\(prefs.primaryAntiCoagulantName)")
                        )
                        .foregroundStyle(prefs.chartAnticoagulantColor)
                        .interpolationMethod(.linear)
                        .symbol(Circle())

                        PointMark(
                            x: .value(
                                "Date",
                                item.timestamp ?? endDate),
                            y: .value(
                                "\(prefs.primaryAntiCoagulantName)",
                                Double(item.dose) / Double(self.anticoagulantAxisMaximum))
                        )
                        .opacity(0)
                        .annotation(position: .overlay, alignment: .bottomLeading, spacing: 10) {
                            Text("\(item.dose)mg").font(.footnote)
                        }

//                        if (prefs.secondaryAntiCoagulantEnabled) {
//                            LineMark(
//                                x: .value("Date", item.timestamp ?? endDate),
//                                y: .value("\(prefs.secondaryAntiCoagulantName)", item.secondaryDose / self.maxSecondaryDoseInRange),
//                                series: .value("Secondary Anticoagulant", "\(prefs.secondaryAntiCoagulantName)")
//                            )
//                            .foregroundStyle(.purple)
//                            .interpolationMethod(.linear)
//                            .symbol(Circle())
//
//                            PointMark(
//                                x: .value("Date", item.timestamp ?? endDate),
//                                y: .value("\(prefs.secondaryAntiCoagulantName)", item.secondaryDose / self.maxSecondaryDoseInRange)
//                            )
//                            .opacity(0)
//                            .annotation(position: .overlay, alignment: .topTrailing, spacing: 10) {
//                                Text("\(item.secondaryDose)mg").font(.footnote)
//                            }
//                        }
                    }
                }
                .padding(.bottom, 5)
                .padding(.horizontal, 5)
                .chartForegroundStyleScale([
                    "INR": prefs.chartINRColor,
                    "\(prefs.primaryAntiCoagulantName)": prefs.chartAnticoagulantColor,
                    "INR Range": prefs.chartINRRangeColor
                ])
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: prefs.graphRange < 14 ? prefs.graphRange : prefs.graphRange / 2)) { value in
                        AxisGridLine()
                        AxisTick()
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
                .chartLegend(position: .overlay, alignment: .bottomLeading, spacing: 10)
                .frame(width: prefs.chartPointWidth * CGFloat(prefs.graphRange), height: K.Chart.chartHeight).padding(10)
            }
        }
    }
}

struct WarfarinINRChart_Previews: PreviewProvider {
    static var previews: some View {
        WarfarinINRChart()
    }
}

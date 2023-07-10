//
//  WarfarinINRChart.swift
//  mInr
//
//  Created by Finn LeSueur on 18/02/23.
//

import SwiftUI
import Charts
import CoreData

struct WarfarinINRChart: View {
    @ObservedObject var dataModel = DataManager.shared
    @ObservedObject var prefs = Prefs.shared
    
    private var inrMeasurements: [INRMeasurement] = []
    private var antiCoagulantDoses: [AntiCoagulantDose] = []
    private var yAxisMaximum: Double = 0.0
    private var endDate: Date = Date.now
    private var startDate: Date = Date.now
    
    init () {
        let now = Date.now
        self.startDate = Calendar.current.date(byAdding: .day, value: prefs.graphRange * -1, to: now) ?? Date.now
        self.endDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? Date.now
        self.inrMeasurements = dataModel.getINRMeasurementsBetween(start: startDate, end: endDate)
        self.antiCoagulantDoses = dataModel.getAntiCoagulantDosesBetween(start: startDate, end: endDate)
        let maxAntiCoagulantDose = dataModel.highestAntiCoagulantDoseInRange(start: startDate, end: endDate)
        let maxINRMeasurement = dataModel.highestINRInRange(start: startDate, end: endDate)
        
        if (maxINRMeasurement.count > 0 && maxAntiCoagulantDose.count > 0) {
            if Double(maxINRMeasurement[0].inr) > Double(maxAntiCoagulantDose[0].dose) {
                self.yAxisMaximum = Double(maxINRMeasurement[0].inr)
            } else {
                self.yAxisMaximum = Double(maxAntiCoagulantDose[0].dose)
            }
            self.yAxisMaximum += 1.0
        } else {
            self.yAxisMaximum = 5
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
                        yStart: .value("Maximum", prefs.maximumINR),
                        yEnd: .value("Minimum", prefs.minimumINR)
                    )
                    .foregroundStyle(K.Colours.INRRange)
                    
                    // Section: INR Measurements
                    ForEach(inrMeasurements) { item in
                        LineMark(
                            x: .value("Date", item.timestamp ?? endDate),
                            y: .value("INR", item.inr),
                            series: .value("Measurement", "INR")
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.linear)
                        .symbol(Circle())
                        
                        PointMark(
                            x: .value("Date", item.timestamp ?? endDate),
                            y: .value("INR", item.inr)
                        )
                        .opacity(0)
                        .annotation(position: .overlay, alignment: .topTrailing, spacing: 10) {
                            Text("\(item.inr, specifier: "%.1f")").font(.footnote)
                        }
                    }
                    
                    // SECTION: Anticoagulant Doses
                    ForEach(antiCoagulantDoses) { item in
                        LineMark(
                            x: .value("Date", item.timestamp ?? endDate),
                            y: .value("\(prefs.primaryAntiCoagulantName)", item.dose),
                            series: .value("Measurement", "\(prefs.primaryAntiCoagulantName)")
                        )
                        .foregroundStyle(.red)
                        .interpolationMethod(.linear)
                        .symbol(Circle())

                        PointMark(
                            x: .value("Date", item.timestamp ?? endDate),
                            y: .value("\(prefs.primaryAntiCoagulantName)", item.dose)
                        )
                        .opacity(0)
                        .annotation(position: .overlay, alignment: .topTrailing, spacing: 10) {
                            Text("\(item.dose)mg").font(.footnote)
                        }

                        if (prefs.secondaryAntiCoagulantEnabled) {
                            LineMark(
                                x: .value("Date", item.timestamp ?? endDate),
                                y: .value("\(prefs.secondaryAntiCoagulantName)", item.secondaryDose),
                                series: .value("Measurement", "\(prefs.secondaryAntiCoagulantName)")
                            )
                            .foregroundStyle(.purple)
                            .interpolationMethod(.linear)
                            .symbol(Circle())

                            PointMark(
                                x: .value("Date", item.timestamp ?? endDate),
                                y: .value("\(prefs.secondaryAntiCoagulantName)", item.secondaryDose)
                            )
                            .opacity(0)
                            .annotation(position: .overlay, alignment: .topTrailing, spacing: 10) {
                                Text("\(item.secondaryDose)mg").font(.footnote)
                            }
                        }
                    }
                }
                .padding(.bottom, 5)
                .padding(.horizontal, 5)
                .chartForegroundStyleScale([
                    "INR": Color.blue,
                    "\(prefs.primaryAntiCoagulantName)": Color.red,
                    "INR Range": Color.green
                ])
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: prefs.graphRange < 14 ? prefs.graphRange : prefs.graphRange / 4)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(values: [0, self.yAxisMaximum])
                }
                .chartLegend(position: .overlay, alignment: .topLeading, spacing: 10)
                .frame(width: K.Chart.dataPointWidth * CGFloat(prefs.graphRange), height: K.Chart.chartHeight)
            }
        }
    }
}

struct WarfarinINRChart_Previews: PreviewProvider {
    static var previews: some View {
        WarfarinINRChart()
    }
}

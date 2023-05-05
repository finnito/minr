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
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("primaryAntiCoagulantName") var primaryAntiCoagulantName: String = "Warfarin"
    @AppStorage("maximumINRRange") var maximumINR: Double = 3.5
    @AppStorage("minimumINRRange") var minimumINR: Double = 2.5
    @AppStorage("graphRange") var graphRange: Int = 14
    
    private var inrMeasurements: [INRMeasurement] = []
    private var antiCoagulantDoses: [AntiCoagulantDose] = []
    private var endDate: Date = Date.now
    private var startDate: Date = Date.now
    
    init () {
        let now = Date.now
        self.startDate = Calendar.current.date(byAdding: .day, value: graphRange * -1, to: now) ?? Date.now
        self.endDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? Date.now
        self.inrMeasurements = dataModel.getINRMeasurementsBetween(start: startDate, end: endDate)
        self.antiCoagulantDoses = dataModel.getAntiCoagulantDosesBetween(start: startDate, end: endDate)
    }
    
    // Form the view
    var body: some View {
        VStack {
            Text("Last \(graphRange) Days")
                    .sectionHeaderStyle()
            VStack {
                HStack(alignment: .center) {
                    Spacer()
                    Text("INR").foregroundColor(.red).font(.footnote)
                    Text("\(primaryAntiCoagulantName)").foregroundColor(.blue).font(.footnote)
                    Text("INR Range").foregroundColor(.green).font(.footnote)
                    Spacer()
                }.padding(.top, 5)
                
                ScrollView(.horizontal) {
                    Chart {
                        RectangleMark(
                            xStart: nil,
                            xEnd: nil,
                            yStart: .value("Maximum", maximumINR),
                            yEnd: .value("Minimum", minimumINR)
                        )
                        .foregroundStyle(.green.opacity(0.25))
                        
                        // Graph inr measurements
                        ForEach(inrMeasurements) { item in
                            LineMark(
                                x: .value("Date", item.timestamp ?? endDate),
                                y: .value("INR", item.inr),
                                series: .value("Measurement", "INR")
                            )
                            .foregroundStyle(.red)
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
                        
                        // Graph warfarin doses
                        ForEach(antiCoagulantDoses) { item in
                            LineMark(
                                x: .value("Date", item.timestamp ?? endDate),
                                y: .value("\(primaryAntiCoagulantName)", item.dose),
                                series: .value("Measurement", "\(primaryAntiCoagulantName)")
                            )
                            .foregroundStyle(.blue)
                            .interpolationMethod(.linear)
                            .symbol(Circle())
                            
                            PointMark(
                                x: .value("Date", item.timestamp ?? endDate),
                                y: .value("\(primaryAntiCoagulantName)", item.dose)
                            )
                            .opacity(0)
                            .annotation(position: .overlay, alignment: .topTrailing, spacing: 10) {
                                Text("\(item.dose)g").font(.footnote)
                            }
                        }
                    }
                    .padding(.bottom, 5)
                    .padding(.horizontal, 5)
                    .chartForegroundStyleScale([
                        "INR": Color.red,
                        "\(primaryAntiCoagulantName)": Color.blue,
                        "INR Range": Color.green
                    ])
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: graphRange < 14 ? graphRange : graphRange / 4)) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel()
                        }
                    }
                    .chartLegend(.hidden)
                    .frame(width: ViewConstants.dataPointWidth * CGFloat(graphRange), height: ViewConstants.chartHeight)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? .white.opacity(0.1) : .white)
                    .shadow(
                        color: Color.gray.opacity(0.25),
                        radius: 10,
                        x: 0,
                        y: 0
                    )
            )
        }
    }
    
    private struct ViewConstants {
        static let color1 = Color(hue: 0.33, saturation: 0.81, brightness: 0.76)
        static let minYScale = 150
        static let maxYScale = 240
        static let chartWidth: CGFloat = 350
        static let chartHeight: CGFloat = 325
        static let dataPointWidth: CGFloat = 25
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct WarfarinINRChart_Previews: PreviewProvider {
    static var previews: some View {
        WarfarinINRChart()
    }
}

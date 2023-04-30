//
//  AddINRView.swift
//  mInr
//
//  Created by Finn LeSueur on 28/03/23.
//

import SwiftUI
import CoreData

struct AddINRView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var dataModel = DataManager.shared
    @State private var inrMeasurement: Double = 0.0
    @State private var inrMeasurementDate = Date()
    
    var body: some View {
        VStack {
            HStack {
                Text("INR Measurement").sectionHeaderStyle()
                Spacer()
                NavigationLink(destination: AllINRDataView()) {
                    Text("All Data")
                }
                .font(.footnote)
            }.padding(.horizontal, 5)
            VStack {
                DatePicker(
                    "Date",
                    selection: $inrMeasurementDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                HStack {
                    Label("INR:", systemImage: "testtube.2")
                    TextField(
                        "1.5",
                        value: $inrMeasurement,
                        format: .number
                    )
                    .keyboardType(.decimalPad)
                    
                    Button(action: {
                        withAnimation {
                            do {
                                _ = try dataModel.addINRMeasurement(inr: inrMeasurement, timestamp: inrMeasurementDate)
                                hideKeyboard()
                                self.inrMeasurement = 0.0
                                self.inrMeasurementDate = Date()
                            } catch let error {
                                print("Couldn't add INR measurement: \(error.localizedDescription)")
                            }
                        }
                    }, label: {
                        Label("Add", systemImage: "cross.circle")
                    })
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(5)
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
}

struct AddINRView_Previews: PreviewProvider {
    static var previews: some View {
        AddINRView()
    }
}

//
//  AddINRView.swift
//  mInr
//
//  Created by Finn LeSueur on 28/03/23.
//

import SwiftUI
import CoreData
import os

struct AddINRView: View {
    @ObservedObject var dataModel = DataManager.shared
    @ObservedObject var prefs = Prefs.shared
    @State private var inrMeasurementDate = Date()
    @FocusState private var fieldFocused: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Text("Add INR Measurement").sheetHeaderStyle()
                    .font(.footnote)
            }.padding(.horizontal, 5)
            VStack {
                DatePicker(
                    "Date",
                    selection: $inrMeasurementDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                HStack {
                    Label("INR", systemImage: K.SFSymbols.inr)
                    Spacer()
                    Stepper(value: $prefs.inrMeasurement, in: 0...30, step: 0.1) {
                        Text("\(prefs.inrMeasurement.formatted())")
                    }
                }
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            do {
                                _ = try dataModel.addINRMeasurement(inr: prefs.inrMeasurement, timestamp: inrMeasurementDate)
                                presentationMode.wrappedValue.dismiss()
                            } catch let error {
                                Logger().fault("AddINRView: Couldn't add INR measurement. \(error.localizedDescription)")
                            }
                        }
                    }, label: {
                        Label("Add", systemImage: K.SFSymbols.add)
                    })
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(5)
            Spacer()
        }
    }
}

struct AddINRView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddINRView()
        }
    }
}

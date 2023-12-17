//
//  AddWarfarinView.swift
//  mInr
//
//  Created by Finn LeSueur on 28/03/23.
//

import SwiftUI
import os

struct AddWarfarinView: View {
    @ObservedObject var dataModel = DataManager.shared
    @ObservedObject var prefs = Prefs.shared
    
    @State private var warfarinDoseDate = Date()
    @State private var note: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Add Anticoagulant Dose").sheetHeaderStyle()
            
            DatePicker(
                "Date",
                selection: $warfarinDoseDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            
            // SECTION: Primary anticoagulant
            HStack {
                Label("\(prefs.primaryAntiCoagulantName):", systemImage: K.SFSymbols.anticoagulant)
                Stepper(value: prefs.$primaryAntiCoagulantDose, in: 0...30, step: 1) {
                    Text("\(prefs.primaryAntiCoagulantDose)mg")
                }
            }
            
            if (prefs.secondaryAntiCoagulantEnabled) {
                HStack {
                    Label("\(prefs.secondaryAntiCoagulantName):", systemImage: K.SFSymbols.anticoagulant)
                    Stepper(value: prefs.$secondaryAntiCoagulantDose, in: 0...30, step: 1) {
                        Text("\(prefs.secondaryAntiCoagulantDose)mg")
                    }
                }
            }
            
            // SECTION: Note
            HStack {
                Label("Note:", systemImage: K.SFSymbols.note)
                TextField("Optional Note", text: $note)
            }
            
            // SECTION: Button
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        do {
                            _ = try dataModel.addAntiCoagulantDose(
                                dose: Int32(prefs.primaryAntiCoagulantDose),
                                secondaryDose: prefs.secondaryAntiCoagulantEnabled ? Int32(prefs.secondaryAntiCoagulantDose) : 0,
                                note: note,
                                timestamp: warfarinDoseDate
                            )
                            presentationMode.wrappedValue.dismiss()
                            NotificationsViewController().updateWarfarinReminder()
                        } catch let error {
                            Logger().fault("Couldn't add anticoagulantdose: \(error.localizedDescription)")
                        }
                    }
                }, label: {
                    Label("Add", systemImage: K.SFSymbols.add)
                })
                .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
    }
}

struct AddWarfarinView_Previews: PreviewProvider {
    static var previews: some View {
        AddWarfarinView()
    }
}

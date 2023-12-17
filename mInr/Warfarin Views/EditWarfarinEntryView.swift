//
//  EditEntryView.swift
//  mInr
//
//  Created by Finn LeSueur on 14/02/23.
//

import SwiftUI

struct EditWarfarinEntryView: View {
    @ObservedObject var dataModel = DataManager.shared
    @ObservedObject var prefs = Prefs.shared
    @Environment(\.dismiss) var dismiss
    @ObservedObject var entry: FetchedResults<AntiCoagulantDose>.Element
    @FocusState private var fieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Label("\(prefs.primaryAntiCoagulantName):", systemImage: K.SFSymbols.anticoagulant)
                        Stepper(value: $entry.dose, in: 0...30, step: 1) {
                            Text("\(entry.dose)mg")
                        }
//                        TextField(
//                            "4",
//                            value: $entry.dose,
//                            format: .number
//                        )
//                        .keyboardType(.decimalPad)
//                        .focused($fieldFocused)
//                        .onAppear {
//                            fieldFocused = true
//                        }
                    }
                    
                    if (prefs.secondaryAntiCoagulantEnabled) {
                        HStack {
                            Label("\(prefs.secondaryAntiCoagulantName):", systemImage: K.SFSymbols.anticoagulant)
                            Stepper(value: $entry.secondaryDose, in: 0...30, step: 1) {
                                Text("\(entry.secondaryDose)mg")
                            }
//                            TextField(
//                                "4",
//                                value: $entry.secondaryDose,
//                                format: .number
//                            )
//                            .keyboardType(.decimalPad)
                        }
                    }
                    
                    HStack {
                        Label("Note:", systemImage: K.SFSymbols.note)
                        TextField("Optional Note", text: $entry.note.boundString)
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            dataModel.updateAnticoagulantEntry(item: entry)
                            dismiss()
                        }, label: {
                            Label("Save", systemImage: K.SFSymbols.save)
                        })
                    }
                }
            }.navigationTitle(Text(entry.timestamp!, formatter: K.entryDateFormatter))
        }
    }
}

struct EditWarfarinEntryView_Previews: PreviewProvider {
    static var previews: some View {
        EditWarfarinEntryView(entry: DataManager.shared.mostRecentAnticoagulantDose()[0])
    }
}

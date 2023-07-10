//
//  EditEntryView.swift
//  mInr
//
//  Created by Finn LeSueur on 14/02/23.
//

import SwiftUI

struct EditINREntryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataModel = DataManager.shared
    @ObservedObject var entry: FetchedResults<INRMeasurement>.Element
    @FocusState private var fieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Label("INR", systemImage: K.SFSymbols.inr)
                        TextField(
                            "1.5",
                            value: $entry.inr,
                            format: .number
                        ).keyboardType(.decimalPad)
                        .focused($fieldFocused)
                        .onAppear {
                            fieldFocused = true
                        }
                    }
                    HStack {
                        Spacer()
                        Button(action: {
                            dataModel.updateINREntry(item: entry)
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

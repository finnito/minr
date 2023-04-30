//
//  EditEntryView.swift
//  mInr
//
//  Created by Finn LeSueur on 14/02/23.
//

import SwiftUI

struct EditWarfarinEntryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataModel = DataManager.shared
    @State var entry: FetchedResults<AntiCoagulantDose>.Element
    @FocusState private var keyboardFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // These are two-way binded to the variable above
                    // by using a $.
                    HStack {
                        Label("Warfarin", systemImage: "pills.fill")
                        TextField(
                            "4",
                            value: $entry.dose,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .focused($keyboardFocused)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                keyboardFocused = true
                            }
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            dataModel.updateAnticoagulantEntry(item: entry)
                            dismiss()
                        }, label: {
                            Label("Save", systemImage: "checkmark.diamond.fill")
                        })
                    }
                }
            }.navigationTitle(Text(entry.timestamp!, formatter: itemFormatter))
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

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
    @State var entry: FetchedResults<INRMeasurement>.Element
    @FocusState private var keyboardFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Label("INR", systemImage: "testtube.2")
                        TextField(
                            "1.5",
                            value: $entry.inr,
                            format: .number
                        ).keyboardType(.decimalPad)
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
                            dataModel.updateINREntry(item: entry)
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

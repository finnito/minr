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
                        Stepper(value: $entry.inr, in: 0...30, step: 0.1) {
                            Text("\(entry.inr.formatted())")
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

struct EditINREntryView_Previews: PreviewProvider {
    static var previews: some View {
        EditINREntryView(entry: DataManager.shared.mostRecentINRMeasurement()[0])
    }
}

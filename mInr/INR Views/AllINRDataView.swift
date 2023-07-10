//
//  AllDataView.swift
//  mInr
//
//  Created by Finn LeSueur on 14/02/23.
//

import SwiftUI

struct AllINRDataView: View {
    @ObservedObject var dataModel = DataManager.shared
    
    var body: some View {
        NavigationStack{
            List {
                ForEach(dataModel.inrMeasurements) { item in
                    NavigationLink(destination: EditINREntryView(entry: item)) {
                        VStack(alignment: .leading) {
                            Text(item.timestamp!, formatter: K.entryDateFormatter)
                                .font(.footnote)
                            Label("INR: \(item.inr, specifier: "%.1f")", systemImage: K.SFSymbols.inr)
                        }
                    }
                }.onDelete(perform: dataModel.deleteINRItems).navigationTitle("All INR Data")
            }.toolbar {
                EditButton()
            }
            .modifier(EmptyDataModifier(
                items: dataModel.inrMeasurements,
                placeholder: Text("No INR Entries").font(.title))
            )
        }.navigationTitle("All INR Data")
    }
}

struct AllINRDataView_Previews: PreviewProvider {
    static var previews: some View {
        AllINRDataView()
    }
}

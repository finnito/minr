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
                            Text(item.timestamp!, formatter: itemFormatter)
                                .font(.footnote)
                            Label("INR: \(item.inr, specifier: "%.1f")", systemImage: "testtube.2")
                        }
                    }
                }.onDelete(perform: dataModel.deleteINRItems).navigationTitle("All INR Data")
            }.toolbar {
                EditButton()
            }
        }.navigationTitle("All INR Data")
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct AllINRDataView_Previews: PreviewProvider {
    static var previews: some View {
        AllINRDataView()
    }
}

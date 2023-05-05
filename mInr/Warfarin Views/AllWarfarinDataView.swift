//
//  AllDataView.swift
//  mInr
//
//  Created by Finn LeSueur on 14/02/23.
//

import SwiftUI

struct AllWarfarinDataView: View {
    @ObservedObject var dataModel = DataManager.shared
    @AppStorage("primaryAntiCoagulantName") var primaryAntiCoagulantName: String = "Warfarin"
    
    var body: some View {
        NavigationStack{
            List {
                ForEach(dataModel.allAntiCoagulantDoses()) { item in
                    NavigationLink(destination: EditWarfarinEntryView(entry: item)) {
                        VStack(alignment: .leading) {
                            Text(item.timestamp!, formatter: dateOnlyFormatter)
                                .font(.footnote)
                            Label("\(primaryAntiCoagulantName): \(item.dose)g", systemImage: "pills.fill")
                        }
                    }
                }.onDelete(perform: dataModel.deleteWarfarinItems).navigationTitle("All \(primaryAntiCoagulantName) Data")
            }.toolbar {
                EditButton()
            }
        }.navigationTitle("All \(primaryAntiCoagulantName) Data")
    }
}

struct AllDataView_Previews: PreviewProvider {
    static var previews: some View {
        AllWarfarinDataView()
    }
}

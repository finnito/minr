//
//  AllDataView.swift
//  mInr
//
//  Created by Finn LeSueur on 14/02/23.
//

import SwiftUI

struct AllWarfarinDataView: View {
    @ObservedObject var dataModel = DataManager.shared
    @ObservedObject var prefs = Prefs.shared
    
    var body: some View {
        NavigationStack{
            List {
                ForEach(dataModel.allAntiCoagulantDoses()) { item in
                    NavigationLink(destination: EditWarfarinEntryView(entry: item)) {
                        VStack(alignment: .leading) {
                            Text(item.timestamp!, formatter: K.entryDateFormatter)
                                .font(.footnote)
                            if (prefs.secondaryAntiCoagulantEnabled) {
                                Label("\(prefs.primaryAntiCoagulantName): \(item.dose)mg\n\(prefs.secondaryAntiCoagulantName): \(item.secondaryDose)mg", systemImage: K.SFSymbols.anticoagulant)
                            } else {
                                Label("\(prefs.primaryAntiCoagulantName): \(item.dose)mg", systemImage: K.SFSymbols.anticoagulant)
                            }
                            
                            if item.note != "" {
                                HStack {
                                    Label("\(item.note ?? "")", systemImage: K.SFSymbols.note)
                                }
                            }
                        }
                    }
                }.onDelete(perform: dataModel.deleteWarfarinItems).navigationTitle("All \(prefs.primaryAntiCoagulantName) Data")
            }.toolbar {
                EditButton()
            }
            .modifier(EmptyDataModifier(
                items: dataModel.allAntiCoagulantDoses(),
                placeholder: Text("No \(prefs.primaryAntiCoagulantName) Entries").font(.title))
            )
        }.navigationTitle("All \(prefs.primaryAntiCoagulantName) Data")
    }
}

struct AllDataView_Previews: PreviewProvider {
    static var previews: some View {
        AllWarfarinDataView()
    }
}

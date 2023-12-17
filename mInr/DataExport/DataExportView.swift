//
//  DataExportView.swift
//  mInr
//
//  Created by Finn LeSueur on 4/07/23.
//

import SwiftUI
import TabularData

struct ActivityView: UIViewControllerRepresentable {
    @Binding var items: [URL]
    @Binding var showing: Bool

    func makeUIViewController(context: Context) -> UIActivityViewController {
        print(items)
        let vc = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        vc.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            self.showing = false
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

struct DataExportView: View {
    @ObservedObject var dataModel = DataManager.shared
    @Environment(\.prefs) private var prefs
    
    @State var showSheet = false
    @State var items = [URL]()
    
    var body: some View {
        NavigationStack{
            Form {
                Text("Your data is synced using Apple's CloudKit, but, you may export it to do any other processing or backups that you desire.")
                Text("Simply click the export button below and save the files. It may take a few seconds for the files to be generated.")
                Button {
//                    print("START DATA EXPORT")
                    let inrDataFrame = getINRDataFrame()
//                    print(inrDataFrame)
                    
                    let acdDataFrame = getAntiCoagulantDataFrame()
//                    print(acdDataFrame)
                    
                    let INRCSVURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent("INR_Data_Export")
                        .appendingPathExtension("csv")
                    do {
                        try inrDataFrame.writeCSV(to: INRCSVURL)
//                        print("Wrote INR data to \(INRCSVURL)")
                        self.items.append(INRCSVURL)
                    } catch {
                        print("Count not write INR data to CSV file.")
                    }
                    
                    let ACDCSVURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent("Anticoagulant_Data_Export")
                        .appendingPathExtension("csv")
                    do {
                        try acdDataFrame.writeCSV(to: ACDCSVURL)
//                        print("Wrote anticoagulant data to \(ACDCSVURL)")
                        self.items.append(ACDCSVURL)
                    } catch {
                        print("Count not write anticoagulant data to CSV file.")
                    }
                    
//                    print("Items: \(self.items)")
//                    print("Toggling on share sheet.")
                    self.showSheet.toggle()
//                    }
                    
                } label: {
                    HStack {
                        Spacer()
                        Text("Export Data")
                        Image(systemName: K.SFSymbols.export)
                    }
                }.sheet(isPresented: $showSheet) {
                    ActivityView(items: $items, showing: $showSheet)
                }
            }
        }.navigationTitle("Data Export")
    }
    
    func getINRDataFrame() -> DataFrame {
        let allINREntries = dataModel.allINRMeasurements()
        
        var dataFrame = DataFrame()
        let capacity = allINREntries.count
        
        let timestampColumn = Column<String>(name: "Timestamp", capacity: capacity)
        let inrColumn = Column<Double>(name: "INR", capacity: capacity)
        
        dataFrame.append(column: timestampColumn)
        dataFrame.append(column: inrColumn)
        
        for entry in allINREntries {
            dataFrame.append(valuesByColumn: [
                "Timestamp": entry.timestamp?.ISO8601Format(),
                "INR": entry.inr
            ])
        }
        
        return dataFrame
    }
    
    func getAntiCoagulantDataFrame() -> DataFrame {
        let allAntiCoagulantEntries = dataModel.allAntiCoagulantDoses()
        
        var dataFrame = DataFrame()
        let capacity = allAntiCoagulantEntries.count
        
        let timestampColumn = Column<String>(name: "Timestamp", capacity: allAntiCoagulantEntries.count)
        let primaryAnticoagulantColumn = Column<Int32>(name: "\(prefs.primaryAntiCoagulantName)", capacity: capacity)
        let secondaryAnticoagulantColumn = Column<Int32>(name: "\(prefs.secondaryAntiCoagulantName)", capacity: capacity)
        let noteColumn = Column<String>(name: "Note", capacity: capacity)
        
        dataFrame.append(column: timestampColumn)
        dataFrame.append(column: primaryAnticoagulantColumn)
        dataFrame.append(column: secondaryAnticoagulantColumn)
        dataFrame.append(column: noteColumn)
        
        for entry in allAntiCoagulantEntries {
            dataFrame.append(valuesByColumn: [
                "Timestamp": entry.timestamp?.ISO8601Format(),
                "\(prefs.primaryAntiCoagulantName)": entry.dose,
                "\(prefs.secondaryAntiCoagulantName)": entry.secondaryDose,
                "Note": entry.note ?? ""
            ])
        }
        
        return dataFrame
    }
}

struct DataExportView_Previews: PreviewProvider {
    static var previews: some View {
        DataExportView()
    }
}

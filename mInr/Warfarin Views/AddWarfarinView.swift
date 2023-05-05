//
//  AddWarfarinView.swift
//  mInr
//
//  Created by Finn LeSueur on 28/03/23.
//

import SwiftUI

struct AddWarfarinView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var dataModel = DataManager.shared
    @State private var warfarinDose: Int32 = 0
    @State private var warfarinDoseDate = Date()
    @AppStorage("primaryAntiCoagulantName") var primaryAntiCoagulantName: String = "Warfarin"
    
    var body: some View {
        VStack {
            HStack {
                Text("\(primaryAntiCoagulantName) Dose").sectionHeaderStyle()
                Spacer()
                NavigationLink(destination: AllWarfarinDataView()) {
                    Text("All Data")
                }
                .font(.footnote)
            }.padding(.horizontal, 5)
            
            
            VStack {
                DatePicker(
                    "Date",
                    selection: $warfarinDoseDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                HStack {
                    HStack {
                        Label("\(primaryAntiCoagulantName):", systemImage: "pills.fill")
                        TextField(
                            "4",
                            value: $warfarinDose,
                            format: .number
                        )
                        .keyboardType(.numberPad)
                        
                        Button(action: {
                            withAnimation {
                                do {
                                    _ = try dataModel.addAntiCoagulantDose(dose: warfarinDose, timestamp: warfarinDoseDate)
                                    hideKeyboard()
                                    self.warfarinDose = 0
                                    self.warfarinDoseDate = Date()
                                } catch let error {
                                    print("Couldn't add anticoagulantdose: \(error.localizedDescription)")
                                }
                            }
                        }, label: {
                            Label("Add", systemImage: "cross.circle")
                        })
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? .white.opacity(0.1) : .white)
                    .shadow(
                        color: Color.gray.opacity(0.25),
                        radius: 10,
                        x: 0,
                        y: 0
                    )
            )
        }
    }
}

struct AddWarfarinView_Previews: PreviewProvider {
    static var previews: some View {
        AddWarfarinView()
    }
}

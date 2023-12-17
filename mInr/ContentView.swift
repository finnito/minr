//
//  ContentView.swift
//  mInr
//
//  Created by Finn LeSueur on 11/02/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var dataModel = DataManager.shared
    @ObservedObject var prefs = Prefs.shared
    
    @State private var showWebView = false
    @State private var showAddAnticoagulantSheet = false
    @State private var showAddINRSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    
                    // Section
                    // Add Data Buttons
                    HStack {
                        
                        // Section
                        // Add Anticoagulant Button
                        VStack {
                            Button {
                                showAddAnticoagulantSheet = true
                            } label: {
                                Text("\(Image(systemName: K.SFSymbols.inr)) Add INR").largeGradientButtonText()
                            }
                            .largeDynamicGradientButton(colour: prefs.chartINRColor)
                                    .padding(15)
                                    .presentationDetents([.fraction(K.addDataSheetFraction)])
                                    .presentationDragIndicator(.visible)
                            }
                            NavigationLink(destination: AllINRDataView()) {
                                Text("All INR Data")
                                    .frame(maxWidth: .infinity)
                            }
                            .font(.footnote)
                            .buttonStyle(.bordered)
                            .tint(prefs.chartINRColor)
                        }
                        
                        
                        // Section
                        // Add INR Button
                        VStack {
                            Button {
                                showAddINRSheet = true
                            } label: {
                                Text("\(Image(systemName: K.SFSymbols.anticoagulant)) Add Dose").largeGradientButtonText()
                            }
                            .sheet(isPresented: $showAddINRSheet) {
                                AddINRView()
                            .largeDynamicGradientButton(colour: prefs.chartAnticoagulantColor)
                                    .padding(15)
                                    .presentationDetents([.fraction(K.addDataSheetFraction)])
                                    .presentationDragIndicator(.visible)
                            }
                            
                            NavigationLink(destination: AllWarfarinDataView()) {
                                Text("All \(prefs.primaryAntiCoagulantName) Data")
                                    .frame(maxWidth: .infinity)
                            }
                            .font(.footnote)
                            .buttonStyle(.bordered)
                            .tint(prefs.chartAnticoagulantColor)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Section
                    // Warfarin Chart
                    Text("\(Image(systemName: K.SFSymbols.graph)) Last \(prefs.graphRange) Days").customHeaderStyle()
                    WarfarinINRChart()
                        .card(fillColour: colorScheme == .dark ? K.Colours.cardBackgroundDark : K.Colours.cardBackgroundLight)
                    // Section
                    // Medication Adherence Chart
                    Text("\(Image(systemName: K.SFSymbols.anticoagulant)) Medication Aherence").customHeaderStyle()
                    CalendarView(
                        interval: DateInterval(start: .distantPast, end: Date())
                    )
                    .card(fillColour: colorScheme == .dark ? K.Colours.cardBackgroundDark : K.Colours.cardBackgroundLight)
                    
                    
                    // Section
                    // In-App Purchases
                    Text("\(Image(systemName: K.SFSymbols.money)) Support The App").customHeaderStyle()
                    StoreView()
                        .card(fillColour: colorScheme == .dark ? K.Colours.cardBackgroundDark : K.Colours.cardBackgroundLight)
                        .fullScreenCover(isPresented: $prefs.showFirstRunView) {
                            FirstRunView()
                        }
                    
                    // Section
                    // Toolbar
                    // Applies to last element
                    .navigationTitle("Home")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        Button {
                            showWebView.toggle()
                        } label: {
                            Label("", systemImage: "questionmark.circle")
                        }.sheet(isPresented: $showWebView) {
                            SFSafariViewWrapper(url: URL(string: K.helpURL)!)
                        }
                        NavigationLink(destination: SettingsView()) {
                            Label("", systemImage: "gear")
                        }
                    }
                }
            }
        }.tint(colorScheme == .dark ? prefs.darkAccentColour : prefs.lightAccentColour)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

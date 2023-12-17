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
                            .largeGradientButton(
                                colour1: Color(red: 237/255, green: 33/255, blue: 58/255),
                                colour2: Color(red: 147/255, green: 41/255, blue: 30/255))
                            .sheet(isPresented: $showAddAnticoagulantSheet) {
                                AddWarfarinView()
                                    .padding(15)
                                    .presentationDetents([.fraction(K.addDataSheetFraction)])
                                    .presentationDragIndicator(.visible)
                            }
                            
                            NavigationLink(destination: AllWarfarinDataView()) {
                                Text("All \(prefs.primaryAntiCoagulantName) Data")
                            }
                            .font(.footnote)
                            .buttonStyle(.bordered)
                        }
                        
                        
                        // Section
                        // Add INR Button
                        VStack {
                            Button {
                                showAddINRSheet = true
                            } label: {
                                Text("\(Image(systemName: K.SFSymbols.anticoagulant)) Add Dose").largeGradientButtonText()
                            }
                            .largeGradientButton(
                                colour1: Color(red: 0/255, green: 180/255, blue: 219/255),
                                colour2: Color(red: 0/255, green: 131/255, blue: 176/255))
                            .sheet(isPresented: $showAddINRSheet) {
                                AddINRView()
                                    .padding(15)
                                    .presentationDetents([.fraction(K.addDataSheetFraction)])
                                    .presentationDragIndicator(.visible)
                            }
                            NavigationLink(destination: AllINRDataView()) {
                                Text("All INR Data")
                            }
                            .font(.footnote)
                            .buttonStyle(.bordered)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

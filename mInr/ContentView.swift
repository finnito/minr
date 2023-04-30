//
//  ContentView.swift
//  mInr
//
//  Created by Finn LeSueur on 11/02/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var dataModel = DataManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var showWebView = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                AddWarfarinView()
                    .padding(10)
                
                AddINRView()
                    .padding(10)
                
                WarfarinINRChart()
                    .padding(10)
                
                Text("Warfarin Compliance")
                    .sectionHeaderStyle()
                    .padding(.top, 10)
                    .padding(.horizontal, 15)
            
                CalendarView(
                    interval: DateInterval(start: .distantPast, end: Date())
                )
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
                .padding(.top, 0)
                .padding(.horizontal, 10)
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button {
                        showWebView.toggle()
                    } label: {
                        Label("", systemImage: "questionmark.circle")
                    }.sheet(isPresented: $showWebView) {
                        SFSafariViewWrapper(url: URL(string: "https://finn.lesueur.nz/minr-help.html")!)
                    }
                    NavigationLink(destination: SettingsView()) {
                        Label("", systemImage: "gear")
                    }
                }
                
                StoreView()
                    .padding(10)
            }.background(Color(UIColor.systemGroupedBackground))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

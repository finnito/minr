//
//  mInrApp.swift
//  mInr
//
//  Created by Finn LeSueur on 11/02/23.
//

import SwiftUI

@main
struct mInrApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

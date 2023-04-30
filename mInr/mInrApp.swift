//
//  mInrApp.swift
//  mInr
//
//  Created by Finn LeSueur on 11/02/23.
//

import SwiftUI

@main
struct mInrApp: App {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("lightAccentColour") var lightAccentColour: Color = .red
    @AppStorage("darkAccentColour") var darkAccentColour: Color = .yellow
    @StateObject private var dataModel = DataManager()
    
    let persistenceController = PersistenceController.shared
    
    init(appModel: DataManager) {
        _dataModel = StateObject(wrappedValue: appModel)
    }
    
    init() {
        registerForNotification()
    }
    
    func registerForNotification() {
        //For device token and push notifications.
        UIApplication.shared.registerForRemoteNotifications()
        let center : UNUserNotificationCenter = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound , .alert , .badge ], completionHandler: { (granted, error) in
            if ((error != nil)) { UIApplication.shared.registerForRemoteNotifications() }
        })
    }
    
    func getCurrentSystemColorScheme() -> ColorScheme {
        let userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
        if userInterfaceStyle == .light {
            return .light
        } else if userInterfaceStyle == .dark {
            return .dark
        }
        return .light
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataModel)
                .tint(getCurrentSystemColorScheme() == .dark ? darkAccentColour : lightAccentColour)
        }
    }
}

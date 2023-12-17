//
//  mInrApp.swift
//  mInr
//
//  Created by Finn LeSueur on 11/02/23.
//

import SwiftUI
import NotificationCenter

@main
struct mInrApp: App {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var dataModel = DataManager()
    @StateObject private var purchaseManager = PurchaseManager()
    @StateObject var prefs: Prefs = Prefs()
    
    let persistenceController = PersistenceController.shared
    
    init(appModel: DataManager) {
        _dataModel = StateObject(wrappedValue: appModel)
    }
    private var notificationDelegate = NotificationsViewController()
    
    init() {
        Logger().info("mInrApp: registerForNotification()")
        registerForNotification()
        
        Logger().info("mInrApp: set notificationDelegate and registerCategories()")
        UNUserNotificationCenter.current().delegate = notificationDelegate
        notificationDelegate.registerCategories()
    }
    
    // This function manages the requesting
    // of user permission to show notifications.
    func registerForNotification() {
        let center : UNUserNotificationCenter = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound , .alert , .badge ], completionHandler: { (granted, error) in
            if ((error != nil)) {
                center.delegate = notificationDelegate
            }
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
//                .environment(\.prefs, prefs)
                .environmentObject(prefs)
                .environmentObject(dataModel)
                .environmentObject(purchaseManager)
                .tint(getCurrentSystemColorScheme() == .dark ? prefs.darkAccentColour : prefs.lightAccentColour)
                .task {
                    await purchaseManager.updatePurchasedProducts()
                }
        }
    }
}

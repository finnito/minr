//
//  mInrApp.swift
//  mInr
//
//  Created by Finn LeSueur on 11/02/23.
//

import SwiftUI
import NotificationCenter
import os
import TipKit

@main
struct mInrApp: App {
    @StateObject private var dataModel = DataManager.shared
    @StateObject private var purchaseManager = PurchaseManager()
    @StateObject var prefs: Prefs = Prefs()
    
    private var notificationDelegate = NotificationsViewController()
    
    init() {
        Logger().info("mInrApp: init()")
        
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

    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(prefs)
            .environmentObject(dataModel)
            .environmentObject(purchaseManager)
            .task {
                await purchaseManager.updatePurchasedProducts()
            }
            .task {
                try? Tips.configure([
                    .displayFrequency(.daily),
                    .datastoreLocation(.groupContainer(identifier: "group.minr"))
                ])
            }
        }
    }
}

//
//  Persistence.swift
//  mInr
//
//  Created by Finn LeSueur on 11/02/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let startDate = Date()
        for i in 0..<20 {
            let anticoagulantDose = AntiCoagulantDose(context: viewContext)
            anticoagulantDose.timestamp = startDate.addingTimeInterval(TimeInterval(-86400*i))
            anticoagulantDose.dose = Int32.random(in: 1...4)
            
            let inrMeasurement = INRMeasurement(context: viewContext)
            inrMeasurement.timestamp = startDate.addingTimeInterval(TimeInterval(-86400*i))
            inrMeasurement.inr = Double.random(in: 2...4)
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error in PersistenceController preview during save() \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
            }
        }
    }

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "mInr")
        let storeURL = URL.storeURL(for: "group.minr", databaseName: "mInr")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.shouldAddStoreAsynchronously = true
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [storeDescription]
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

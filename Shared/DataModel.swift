//
//  mINRDataModel.swift
//  mInr
//
//  Created by Finn LeSueur on 29/03/23.
//

import CoreData
import SwiftUI
import Combine
import WidgetKit
import os

class DataManager: ObservableObject {
    @Published var inrMeasurements = [INRMeasurement]()
    @Published var antiCoagulantDoses = [AntiCoagulantDose]()
    var changes: [Date] = []
    
    static let shared: DataManager = DataManager()
    let context = PersistenceController.shared.container.viewContext
    
    init(persistenceController: PersistenceController = .shared) {
        Logger().info("DataManager: init()")
        self.inrMeasurements = self.allINRMeasurements()
        self.antiCoagulantDoses = self.allAntiCoagulantDoses()
    }
    
    func GETTotalAnticoagulantTaken() -> Int {
        Logger().info("DataManager: GETTotalAnticoagulantTaken()")
        let request: NSFetchRequest<AntiCoagulantDose> = AntiCoagulantDose.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AntiCoagulantDose.dose, ascending: false)]
        do {
            return try context.fetch(request).reduce(0) {
                $0 + ($1.value(forKey: "dose") as? Int ?? 0)
            }
        } catch let error {
            Logger().info("DataManager: Unable to GETTotalAnticoagulantTaken().\n\(error.localizedDescription)")
            return 0
        }
    }
    
    func GETNumberOfDoses() -> Int {
        Logger().info("DataManager: GETNumberOfDoses()")
        let request: NSFetchRequest<AntiCoagulantDose> = AntiCoagulantDose.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AntiCoagulantDose.dose, ascending: false)]
        do {
            return try context.count(for: request)
        } catch let error {
            Logger().info("DataManager: Unable to GETFirstDose().\n\(error.localizedDescription)")
            return 0
        }
    }
    
    func GETFirstDose() -> AntiCoagulantDose? {
        Logger().info("DataManager: getFirstDose()")
        let request: NSFetchRequest<AntiCoagulantDose> = AntiCoagulantDose.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AntiCoagulantDose.dose, ascending: true)]
        request.fetchLimit = 1
        do {
            return try context.fetch(request)[0]
        } catch let error {
            Logger().info("DataManager: Unable to GETFirstDose().\n\(error.localizedDescription)")
            return nil
        }
    }
    
    func getAnticoagulantDoseBy(start: Date, end: Date) -> [AntiCoagulantDose] {
        Logger().info("DataManager: getAnticoagulantDoseBy(\(start.formatted(date: .numeric, time: .omitted)))")
        let request: NSFetchRequest<AntiCoagulantDose> = AntiCoagulantDose.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AntiCoagulantDose.dose, ascending: false)]
        request.predicate = NSPredicate(
            format: "(timestamp >= %@) AND (timestamp <= %@)",
            argumentArray: [start, end]
        )
        do {
            return try context.fetch(request)
        } catch let error {
            Logger().info("DataManager: Unable to getAnticoagulantDoseBy(\(start), \(end)).\n\(error.localizedDescription)")
            return []
        }
    }
    
    func highestINRInRange(start: Date, end: Date) -> [INRMeasurement] {
        Logger().info("DataManager: highestINRInRange(\(start), \(end))")
        let request: NSFetchRequest<INRMeasurement> = INRMeasurement.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \INRMeasurement.inr, ascending: false)]
        request.predicate = NSPredicate(
            format: "(timestamp >= %@) AND (timestamp <= %@)",
            argumentArray: [start, end]
        )
        do {
            return try context.fetch(request)
        } catch let error {
            print("ERROR: Couldn't fetch highest INR measurement in given range.\n\(error.localizedDescription)")
            return []
        }
    }
    
    func highestAntiCoagulantDoseInRange(start: Date, end: Date) -> [AntiCoagulantDose] {
        Logger().info("DataManager: highestAntiCoagulantDoseInRange(\(start), \(end))")
        let request: NSFetchRequest<AntiCoagulantDose> = AntiCoagulantDose.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AntiCoagulantDose.dose, ascending: false)]
        request.predicate = NSPredicate(
            format: "(timestamp >= %@) AND (timestamp <= %@)",
            argumentArray: [start, end]
        )
        do {
            return try context.fetch(request)
        } catch let error {
            print("ERROR: Couldn't fetch highest anticoagulant dose in given range.\n\(error.localizedDescription)")
            return []
        }
    }
    
    func highestSecondaryAntiCoagulantDoseInRange(start: Date, end: Date) -> [AntiCoagulantDose] {
        Logger().info("DataManager: highestSecondaryAntiCoagulantDoseInRange(\(start), \(end))")
        let request: NSFetchRequest<AntiCoagulantDose> = AntiCoagulantDose.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AntiCoagulantDose.secondaryDose, ascending: false)]
        request.predicate = NSPredicate(
            format: "(timestamp >= %@) AND (timestamp <= %@)",
            argumentArray: [start, end]
        )
        do {
            return try context.fetch(request)
        } catch let error {
            print("ERROR: Couldn't fetch highest secondary anticoagulant dose in given range.\n\(error.localizedDescription)")
            return []
        }
    }
    
    func allAntiCoagulantDoses() -> [AntiCoagulantDose] {
        Logger().info("DataManager: allAntiCoagulantDoses()")
        let request: NSFetchRequest<AntiCoagulantDose> = AntiCoagulantDose.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(
            keyPath: \AntiCoagulantDose.timestamp,
            ascending: false
        )]
        do {
            return try context.fetch(request)
        } catch let error {
            print("ERROR: Couldn't fetch all anticoagulant doses.\n\(error.localizedDescription)")
            return []
        }
    }
    
    func allINRMeasurements() -> [INRMeasurement] {
        Logger().info("DataManager: GET allINRMeasurements()")
        let request: NSFetchRequest<INRMeasurement> = INRMeasurement.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(
            keyPath: \INRMeasurement.timestamp,
            ascending: false
        )]
        do {
            return try context.fetch(request)
        } catch let error {
            print("ERROR: Couldn't fetch all INR measurements.\n\(error.localizedDescription)")
            return []
        }
    }
        
    func addINRMeasurement(inr: Double, timestamp: Date) throws -> INRMeasurement {
        Logger().info("DataManager: INSERT addINRMeasurement(\(inr), \(timestamp))")
        let newINRMeasurement = INRMeasurement(context: context)
        newINRMeasurement.inr = inr
        newINRMeasurement.timestamp = timestamp
        do {
            changes.append(timestamp)
            try saveContext()
            return newINRMeasurement
        } catch let error {
            print("ERROR: Couldn't save INR measurement.\n\(error.localizedDescription)")
            return newINRMeasurement
        }
    }

    func addAntiCoagulantDose(dose: Int32, secondaryDose: Int32, note: String, timestamp: Date) throws -> AntiCoagulantDose {
        Logger().info("DataManager: INSERT addAntiCoagulantDose(\(dose), \(secondaryDose), \(note), \(timestamp))")
        let newAntiCoagulantDose = AntiCoagulantDose(context: context)
        newAntiCoagulantDose.dose = dose
        newAntiCoagulantDose.secondaryDose = secondaryDose
        newAntiCoagulantDose.note = note
        newAntiCoagulantDose.timestamp = timestamp
        do {
            changes.append(timestamp)
            try saveContext()
            return newAntiCoagulantDose
        } catch let error {
            print("ERROR: Couldn't save new anticoagulant dose.\n\(error.localizedDescription)")
            return newAntiCoagulantDose
        }
    }
    
    func mostRecentINRMeasurement() -> [INRMeasurement] {
        Logger().info("DataManager: GET mostRecentINRMeasurement()")
        let request: NSFetchRequest<INRMeasurement> = INRMeasurement.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \INRMeasurement.timestamp,ascending: false)]
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request)
        } catch {
            print("ERROR: Couldn't fetch most recent INRMeasurement.")
            return []
        }
    }
    
    func mostRecentAnticoagulantDose() -> [AntiCoagulantDose] {
        Logger().info("DataManager: GET mostRecentAnticoagulantDose()")
        let request: NSFetchRequest<AntiCoagulantDose> = AntiCoagulantDose.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AntiCoagulantDose.timestamp,ascending: false)]
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request)
        } catch {
            print("ERROR: Couldn't fetch most recent AntiCoagulantDose.")
            return []
        }
    }

    func getINRMeasurementsBetween(start: Date, end: Date) -> [INRMeasurement] {
        Logger().info("DataManager: GET getINRMeasurementsBetween(\(start), \(end)")
        let request: NSFetchRequest<INRMeasurement> = INRMeasurement.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \INRMeasurement.timestamp,ascending: false)]
        request.predicate = NSPredicate(
            format: "(timestamp >= %@) AND (timestamp <= %@)",
            argumentArray: [start, end]
        )
        do {
            return try context.fetch(request)
        } catch let error {
            print("ERROR: Couldn't fetch INR measurements between \(start) and \(end). \(error.localizedDescription)")
            return []
        }
    }

    func getAntiCoagulantDosesBetween(start: Date, end: Date) -> [AntiCoagulantDose] {
        Logger().info("DataManager: GET getAntiCoagulantDosesBetween(\(start), \(end)")
        let request: NSFetchRequest<AntiCoagulantDose> = AntiCoagulantDose.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AntiCoagulantDose.timestamp,ascending: false)]
        request.predicate = NSPredicate(
            format: "(timestamp >= %@) AND (timestamp <= %@)",
            argumentArray: [start, end]
        )
        do {
            return try context.fetch(request)
        } catch let error {
            print("ERROR: Couldn't fetch anticoagulant doses between \(start) and \(end). \(error.localizedDescription)")
            return []
        }
    }

    func deleteWarfarinItems(offsets: IndexSet) {
        Logger().info("DataManager: DELETE deleteWarfarinItems(\(offsets))")
        withAnimation {
            offsets.map() {
                if let item = self.antiCoagulantDoses[$0].timestamp {
                    changes.append(item)
                    Logger().info("DataManager: DELETE \(item)")
                }
                return self.antiCoagulantDoses[$0]

            }.forEach(context.delete)
            do {
                try saveContext()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("ERROR: Couldn't delete anticoagulant entries \(offsets). \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func deleteINRItems(offsets: IndexSet) {
        Logger().info("DataManager: DELETE deleteINRItems(\(offsets))")
        withAnimation {
            offsets.map() {
                if let item = self.inrMeasurements[$0].timestamp {
                    changes.append(item)
                    Logger().info("DataManager: DELETE \(item)")
                }
                return self.inrMeasurements[$0]
            }.forEach(context.delete)
            do {
                try saveContext()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("ERROR: Couldn't delete INR entries \(offsets). \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func updateAnticoagulantEntry(item: FetchedResults<AntiCoagulantDose>.Element) {
        Logger().info("DataManager: UPDATE updateAnticoagulantEntry(\(item))")
        do {
            try saveContext()
            if let timestamp = item.timestamp {
                changes.append(timestamp)
            }
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("ERROR: Couldn't update anticoagulant entry \(item.id). \(nsError), \(nsError.userInfo)")
        }
    }

    func updateINREntry(item: FetchedResults<INRMeasurement>.Element) {
        Logger().info("DataManager: UPDATE updateINREntry(\(item))")
        do {
            try saveContext()
            if let timestamp = item.timestamp {
                changes.append(timestamp)
            }
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("ERROR: Couldn't update INR entry \(item.id). \(nsError), \(nsError.userInfo)")
        }
    }
    
    func saveContext() throws {
        do {
            if context.hasChanges {
                try context.save()
                Logger().info("DataManager: save context")
                self.antiCoagulantDoses = self.allAntiCoagulantDoses()
                self.inrMeasurements = self.allINRMeasurements()
                WidgetCenter.shared.reloadAllTimelines()
                Logger().info("Widgets: Asked to update after saving context.")
            }
        } catch let error {
            print("ERROR: Couldn't save CoreData context: \(error.localizedDescription)")
        }
    }
    
    private var cancellableSet: Set<AnyCancellable> = []
//    init(inMemory: Bool = false) {
//        print("Setting up Core Data update subscriptions  ")
//        CoreDataPublisher(request: INRMeasurement.fetchAllMeasurementsRequest(), context: context)
//            .sink(
//                receiveCompletion: {
//                    print("Completion from fetchAllINRMeasurements")
//                    print($0)
//                },
//                receiveValue: { [weak self] items in
//                    print("Updating inr measurements")
//                    self?.inrMeasurements = items
//                })
//            .store(in: &cancellableSet)
//
//        CoreDataPublisher(request: AntiCoagulantDose.fetchAllDosesRequest(), context: context)
//            .sink(
//                receiveCompletion: {
//                    print("Completion from fetchAllAnticoagulantDoses")
//                    print($0)
//                },
//                receiveValue: { [weak self] items in
//                    print("Updating anticoagulant doses")
//                    self?.antiCoagulantDoses = items
//                })
//            .store(in: &cancellableSet)
//    }
}

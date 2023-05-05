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

class DataManager: ObservableObject {
    @Published var inrMeasurements = [INRMeasurement]()
    @Published var antiCoagulantDoses = [AntiCoagulantDose]()
    var changes: [Date] = []
    
    static let shared: DataManager = DataManager()
    
    let context = PersistenceController.shared.container.viewContext
    
    init() {
        print("DataManager being set up.")
        self.inrMeasurements = self.allINRMeasurements()
        self.antiCoagulantDoses = self.allAntiCoagulantDoses()
    }
    
    func allAntiCoagulantDoses() -> [AntiCoagulantDose] {
        print("GET: All anticoagulant doses.")
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
        print("GET: All INR measurements.")
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
        print("INSERT: INR measurement for \(timestamp).")
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

    func addAntiCoagulantDose(dose: Int32, timestamp: Date) throws -> AntiCoagulantDose {
        print("INSERT: anticoagulant dose for \(timestamp).")
        let newAntiCoagulantDose = AntiCoagulantDose(context: context)
        newAntiCoagulantDose.dose = dose
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
        print("GET: Most recent INR measurement.")
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
        print("GET: Most recent anticoagulant dose.")
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
        print("GET: INR measurements between \(String(describing: start)) and \(String(describing: end)).")
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
        print("GET: anticoagulant doses between \(String(describing: start)) and \(String(describing: end)).")
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
        withAnimation {
            offsets.map() {
                if let item = self.antiCoagulantDoses[$0].timestamp {
                    changes.append(item)
                    print("DELETE: anticoagulant dose for \(item)")
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
        withAnimation {
            offsets.map() {
                if let item = self.inrMeasurements[$0].timestamp {
                    changes.append(item)
                    print("DELETE: INR measurement for \(item)")
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
        print("UPDATE: anticoagulant dose for \(String(describing: item.timestamp))")
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
        print("UPDATE: INR measurement for \(String(describing: item.timestamp))")
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
                print("Saved changes.")
                self.antiCoagulantDoses = self.allAntiCoagulantDoses()
                self.inrMeasurements = self.allINRMeasurements()
                WidgetCenter.shared.reloadAllTimelines()
                print("Asked widgets to update.")
            }
        } catch let error {
            print("ERROR: Couldn't save CoreData context: \(error.localizedDescription)")
        }
    }
    
    private var cancellableSet: Set<AnyCancellable> = []
    init(inMemory: Bool = false) {
        print("Setting up Core Data update subscriptions  ")
        CoreDataPublisher(request: INRMeasurement.fetchAllMeasurementsRequest(), context: context)
            .sink(
                receiveCompletion: {
                    print("Completion from fetchAllINRMeasurements")
                    print($0)
                },
                receiveValue: { [weak self] items in
                    print("Updating inr measurements")
                    self?.inrMeasurements = items
                })
            .store(in: &cancellableSet)

        CoreDataPublisher(request: AntiCoagulantDose.fetchAllDosesRequest(), context: context)
            .sink(
                receiveCompletion: {
                    print("Completion from fetchAllAnticoagulantDoses")
                    print($0)
                },
                receiveValue: { [weak self] items in
                    print("Updating anticoagulant doses")
                    self?.antiCoagulantDoses = items
                })
            .store(in: &cancellableSet)
    }
}

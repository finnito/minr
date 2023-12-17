//
//  Shortcuts_AddWarfarinDose.swift
//  mInr
//
//  Created by Finn LeSueur on 29/03/23.
//

import Foundation
import SwiftUI
import AppIntents
import CoreData

struct AddWarfarinDose: AppIntent {
    static let title: LocalizedStringResource = "Add a anticoagulant dose."
    static let description: IntentDescription = "Adds a anticoagulant dose (mg) to your data."
    static var parameterSummary: some ParameterSummary {
        Summary("Add an anticoagulant dose of \(\.$dose)mg and secondary anticoagulant dose of \(\.$secondaryDose)mg for \(\.$date).")
    }

    @Parameter(title: "Anticoagulant Dose (mg)")
    var dose: Int
    
    @Parameter(title: "Secondary Anticoagulant Dose (mg)")
    var secondaryDose: Int
    
    @Parameter(title: "Optional Note")
    var note: String

    @Parameter(title: "Date")
    var date: Date?

    @MainActor
    func perform() async throws -> some IntentResult {
        if let date = date {
            do {
                let _ = try DataManager.shared.addAntiCoagulantDose(
                    dose: Int32(dose),
                    secondaryDose: Int32(secondaryDose),
                    note: note,
                    timestamp: date
                )
                return .result()
            } catch {
                throw CustomIntentError.message("There was a problem adding your anticoagulant dose. Sorry about that!")
            }
        }
        throw CustomIntentError.message("There was a problem parsing the date your gave.")
    }
}

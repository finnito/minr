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
    static let title: LocalizedStringResource = "Add a warfarin dose."
    static let description: IntentDescription = "Adds a warfarin dose (g) to your data."
    static var parameterSummary: some ParameterSummary {
        Summary("Add a warfarin dose of \(\.$dose)g for \(\.$date).")
    }

    @Parameter(title: "Warfarin Dose (g)")
    var dose: Int

    @Parameter(title: "Date")
    var date: Date?

    @MainActor
    func perform() async throws -> some IntentResult {
        if let date = date {
            do {
                let _ = try DataManager.shared.addAntiCoagulantDose(
                    dose: Int32(dose),
                    timestamp: date
                )
                return .result()
            } catch {
                throw CustomIntentError.message("There was a problem adding your warfarin dose. Sorry about that!")
            }
        }
        throw CustomIntentError.message("There was a problem parsing the date your gave.")
    }
}

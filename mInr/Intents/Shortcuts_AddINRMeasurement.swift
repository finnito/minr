//
//  Shortcuts_AddINRMeasurement.swift
//  mInr
//
//  Created by Finn LeSueur on 02/04/23.
//

import Foundation
import SwiftUI
import AppIntents
import CoreData

struct AddINRMeasurement: AppIntent {
    static let title: LocalizedStringResource = "Add a INR measurement."
    static let description: IntentDescription = "Adds an INR measurement to your data."
    static var parameterSummary: some ParameterSummary {
        Summary("Add an INR measurement of \(\.$inr) on \(\.$date).")
    }

    @Parameter(title: "INR Measurement")
    var inr: Double

    @Parameter(title: "Date")
    var date: Date?

    @MainActor
    func perform() async throws -> some IntentResult {
        if let date = date {
            do {
                let _ = try DataManager.shared.addINRMeasurement(
                    inr: Double(inr),
                    timestamp: date
                )
                return .result()
            } catch {
                throw CustomIntentError.message("There was a problem adding your INR measurement.")
            }
        }
        throw CustomIntentError.message("There was a problem parsing the date you gave.")
    }
}

//
//  ShortcutsWarfarinDoseEntity.swift
//  mInr
//
//  Created by Finn LeSueur on 2/04/23.
//

import Foundation
import AppIntents
import CoreData

struct ShortcutsWarfarinDoseEntity: TransientAppEntity {
    var value: Never?
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Anticoagulant Dose")
    
    @Property(title: "Anticoagulant Dose (mg)")
    var dose: String
    
    @Property(title: "Date")
    var date: String
    
    var displayRepresentation: DisplayRepresentation {
        return DisplayRepresentation(
            title: "\(dose)mg of anticoagulant on \(date).",
            subtitle: ""
        )
    }
}

extension ShortcutsWarfarinDoseEntity {
    init(dose: String, date: String) {
        self.dose = dose
        self.date = date
    }
}

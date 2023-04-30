//
//  ModelExtensions.swift
//  mInr
//
//  Created by Finn LeSueur on 29/03/23.
//

import Foundation
import CoreData

extension INRMeasurement {
    @nonobjc public class func fetchAllMeasurementsRequest() -> NSFetchRequest<INRMeasurement> {
        let request: NSFetchRequest<INRMeasurement> = INRMeasurement.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(
            keyPath: \INRMeasurement.timestamp,
            ascending: false
        )]
        return request
    }
}

extension AntiCoagulantDose {
    @nonobjc public class func fetchAllDosesRequest() -> NSFetchRequest<AntiCoagulantDose> {
        let request: NSFetchRequest<AntiCoagulantDose> = AntiCoagulantDose.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(
            keyPath: \AntiCoagulantDose.timestamp,
            ascending: false
        )]
        return request
    }
}

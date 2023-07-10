//
//  DateExtensions.swift
//  mInr
//
//  Created by Finn LeSueur on 25/03/23.
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var isPastToday: Bool {
        return self < Date()
    }
}

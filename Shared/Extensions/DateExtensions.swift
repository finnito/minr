//
//  DateExtensions.swift
//  mInr
//
//  Created by Finn LeSueur on 25/03/23.
//

import Foundation

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        let startOfDay = Calendar.current.startOfDay(for: self)
        let components = DateComponents(hour: 23, minute: 59, second: 59)
        if let date = Calendar.current.date(byAdding: components, to: startOfDay) {
            return date
        }
        
        return Date()
    }
    
    var isPastToday: Bool {
        return self < Date()
    }
    
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}

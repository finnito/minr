//
//  CalendarExtension.swift
//  WidgetsExtension
//
//  Created by Finn LeSueur on 29/04/23.
//  Source: https://sarunw.com/posts/getting-number-of-days-between-two-dates/

import Foundation

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day!
    }
}

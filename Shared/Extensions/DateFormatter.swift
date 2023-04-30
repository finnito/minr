//
//  DateFormatter.swift
//  mInr
//
//  Created by Finn LeSueur on 2/04/23.
//

import Foundation

let dateOnlyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

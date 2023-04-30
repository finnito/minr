//
//  IntentError.swift
//  mInr
//
//  Created by Finn LeSueur on 2/04/23.
//

import Foundation
import SwiftUI

enum CustomIntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case general
    case message(_ message: String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case let .message(message): return "Error: \(message)"
        case .general: return "General error, unknown."
        }
    }
}

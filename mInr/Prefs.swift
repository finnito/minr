//
//  Settings.swift
//  mInr
//
//  Created by Finn LeSueur on 9/07/23.
//

import Foundation
import SwiftUI

extension Date: RawRepresentable {
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
}

extension Color: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else{
            self = .black
            return
        }
        
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) ?? .black
            self = Color(color)
        } catch {
            self = .black
        }
    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else { return nil }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

extension EnvironmentValues {
    var prefs: Prefs {
        get { self[PrefsKey.self] }
        set { self[PrefsKey.self] = newValue }
    }
}


private struct PrefsKey: EnvironmentKey {
    static var defaultValue: Prefs = Prefs()
}


class Prefs: ObservableObject {
    
    static let shared: Prefs = Prefs()
    
    // Primary Anticoagulant
    @AppStorage("primaryAntiCoagulantName", store: UserDefaults(suiteName: "group.minr"))
    public var primaryAntiCoagulantName: String = "Warfarin"
    
    @AppStorage("primaryAntiCoagulantDose", store: UserDefaults(suiteName: "group.minr"))
    public var primaryAntiCoagulantDose: Int = 4
    
    
    // Secondary Anticoagulant
    @AppStorage("secondaryAntiCoagulantEnabled", store: UserDefaults(suiteName: "group.minr"))
    public var secondaryAntiCoagulantEnabled: Bool = false
    
    @AppStorage("secondaryAntiCoagulantName", store: UserDefaults(suiteName: "group.minr"))
    public var secondaryAntiCoagulantName: String = "Aspirin"
    
    @AppStorage("secondaryAntiCoagulantDose", store: UserDefaults(suiteName: "group.minr"))
    public var secondaryAntiCoagulantDose: Int = 2
    
    
    // INR Measurement
    @AppStorage("inrMeasurement", store: UserDefaults(suiteName: "group.minr"))
    public var inrMeasurement: Double = 0.0
    
    
    // INR Range
    @AppStorage("maximumINRRange", store: UserDefaults(suiteName: "group.minr"))
    public var maximumINR: Double = 3.5
    
    @AppStorage("minimumINRRange", store: UserDefaults(suiteName: "group.minr"))
    public var minimumINR: Double = 2.5
    
    
    // Chart
    @AppStorage("graphRange", store: UserDefaults(suiteName: "group.minr"))
    public var graphRange: Int = 14
    
    // Anticoagulant Reminder
    @AppStorage("warfarinReminderEnabled", store: UserDefaults(suiteName: "group.minr"))
    public var warfarinReminderEnabled: Bool = false
    
    @AppStorage("warfarinReminderTime", store: UserDefaults(suiteName: "group.minr"))
    public var warfarinReminderTime = Date()
    
    @AppStorage("warfarinReminderInterval", store: UserDefaults(suiteName: "group.minr"))
    public var warfarinReminderInterval: Int = 1
    
    @AppStorage("warfarinReminderIdentifier", store: UserDefaults(suiteName: "group.minr"))
    public var warfarinReminderIdentifier: String = ""
    
    // Colours
    @AppStorage("lightAccentColour", store: UserDefaults(suiteName: "group.minr"))
    public var lightAccentColour: Color = .red
    
    @AppStorage("darkAccentColour", store: UserDefaults(suiteName: "group.minr"))
    public var darkAccentColour: Color = .yellow
}

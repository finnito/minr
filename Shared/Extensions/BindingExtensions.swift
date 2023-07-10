//
//  BindingExtensions.swift
//  mInr
//
//  Created by Finn LeSueur on 28/03/23.
//

import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}

// Allows for an optional string in TextField.
// Usage: TextField("Optional Note", text: $entry.note.boundString)
// Source: https://medium.com/geekculture/making-the-most-of-textfields-in-swiftui-5fd80d612502
extension Optional where Wrapped == String {
    var _boundString: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var boundString: String {
        get {
            return _boundString ?? ""
        }
        set {
            _boundString = newValue.isEmpty ? nil : newValue
        }
    }
}

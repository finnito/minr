//
//  ListModifier.swift
//  mInr
//
//  Created by Finn LeSueur on 5/07/23.
//  Source: https://stackoverflow.com/questions/62398534/swiftui-list-empty-state-view-modifier

import SwiftUI

struct EmptyDataModifier<Placeholder: View>: ViewModifier {
    let items: [Any]
    let placeholder: Placeholder

    @ViewBuilder
    func body(content: Content) -> some View {
        if !items.isEmpty {
            content
        } else {
            placeholder
        }
    }
}


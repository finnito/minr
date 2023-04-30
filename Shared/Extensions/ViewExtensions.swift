//
//  ViewExtensions.swift
//  mInr
//
//  Created by Finn LeSueur on 28/03/23.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

extension View {
    func glow(color: Color = .red, radius: CGFloat = 20) -> some View {
        
        self
            .overlay(
                RoundedRectangle(cornerRadius: radius / 3)
                    .stroke(color, lineWidth: 1)
                    .shadow(color: color, radius: radius / 3)
                    .shadow(color: color, radius: radius / 3)
                    .shadow(color: color, radius: radius / 3)
            )
    }
}

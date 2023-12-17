//
//  Constants.swift
//  mInr
//
//  Created by Finn LeSueur on 8/07/23.
//

import Foundation
import SwiftUI

struct K {
    static let helpURL = "https://finn.lesueur.nz/minr-help.html"
    static let addDataSheetFraction: Double = 0.4
    
    struct SFSymbols {
        static let add = "plus.circle"
        static let save = "checkmark.diamond.fill"
        static let inr = "testtube.2"
        static let anticoagulant = "pills.fill"
        static let graph = "chart.xyaxis.line"
        static let alarm = "alarm"
        static let color = "eyedropper.halffull"
        static let icon = "laptopcomputer.and.iphone"
        static let export = "square.and.arrow.down"
        static let note = "note.text"
        static let info = ""
        static let help = "questionmark.circle"
        static let settings = "gear"
        static let tip = "lightbulb"
        static let money = "dollarsign.circle.fill"
        static let statistics = "tablecells"
    }
    
    struct Colours {
        static let INRRange = Color.green.opacity(0.25)
    }
    
    struct Chart {
        static let dataPointWidth: CGFloat = 25.0
        static let chartHeight: CGFloat = 163.0
    }
    
    static let entryDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, MMM d, yyyy"
        return formatter
    }()
}

extension Text {
    func customHeaderStyle() -> some View {
        self
            .font(.system(.title3))
            .fontWeight(.bold)
            .foregroundColor(.primary)
            .textCase(nil)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
            .padding(.horizontal, 20)
    }
    
    func sheetHeaderStyle() -> some View {
        return self
            .multilineTextAlignment(.center)
            .font(.system(.title3))
            .fontWeight(.bold)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
        
    }
}

extension View {
    func card(fillColour: Color) -> some View {
        return self
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(fillColour)
//                    .shadow(
//                        color: Color.gray.opacity(0.25),
//                        radius: 10,
//                        x: 0,
//                        y: 0
//                    )
            )
            .padding(.bottom, 5)
            .padding(.horizontal, 15)
            .padding(.top, 0)
    }
    
    func largeDynamicGradientButton(colour: Color) -> some View {
        return self
            .buttonStyle(.borderless)
            .background(colour.gradient)
            .cornerRadius(10)
            .frame(maxWidth: .infinity)
    }
    
    func largeGradientButtonText() -> some View {
        return self
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
            .foregroundColor(.white)
            .font(.headline)
            .frame(maxWidth: .infinity)
    }
}

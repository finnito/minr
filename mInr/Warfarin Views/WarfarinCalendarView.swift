//
//  CalendarView.swift
//  mInr
//
//  Created by Finn LeSueur on 2/03/23.
//

import SwiftUI
import os

struct CalendarView: UIViewRepresentable {
    @ObservedObject var dataModel = DataManager.shared
    
    let interval: DateInterval
    
    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.delegate = context.coordinator
        view.availableDateRange = interval
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        Logger().info("WarfarinCalendarView: updateUIView()")
        var allComponents = [DateComponents]()
        Logger().info("WarfarinCalendarView: \(dataModel.changes.count) changes detected")
        while dataModel.changes.count > 0 {
            let changedDate = dataModel.changes.removeFirst()
            let components = Calendar.current.dateComponents([.day, .month, .year], from: changedDate)
            allComponents.append(components)
        }
        uiView.reloadDecorations(forDateComponents: [uiView.visibleDateComponents], animated: true)
        Logger().info("WarfarinCalendarView: reloaded decorations for \(allComponents.count) components")
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarView
        init(parent: CalendarView) {
            self.parent = parent
        }
        
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            if dateComponents.date?.timeIntervalSinceNow.sign == FloatingPointSign.plus {
                return nil
            }
            
            // MARK: Anticoagulant Dose Decorations
            let font = UIFont.systemFont(ofSize: 12)
            let configuration = UIImage.SymbolConfiguration(font: font)
            if let date = dateComponents.date {
                let antiCoagulantDose = self.parent.dataModel.getAnticoagulantDoseBy(start: date.startOfDay, end: date.endOfDay)
                if antiCoagulantDose.count == 1 {
                    return .customView {
                        let label = UILabel()
                        label.text = "\(antiCoagulantDose[0].dose)mg"
                        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
                        return label
                    }
                }
            }
            
            let image = UIImage(systemName: "exclamationmark.triangle", withConfiguration: configuration)?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.red)
            
            return .image(image)
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           didSelectDate dateComponents: DateComponents?) {
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           canSelectDate dateComponents: DateComponents?) -> Bool {
            return true
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(interval: DateInterval(
            start: .distantPast,
            end: Date()
        ))
    }
}

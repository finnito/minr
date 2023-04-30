//
//  CalendarView.swift
//  mInr
//
//  Created by Finn LeSueur on 2/03/23.
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    let interval: DateInterval
    @ObservedObject var dataModel = DataManager.shared
    @AppStorage("lightAccentColour") var lightAccentColour: Color = .red
    @AppStorage("darkAccentColour") var darkAccentColour: Color = .yellow
    
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
        print("updateUIView called")
        var allComponents = [DateComponents]()
        print("Changes: \(dataModel.changes)")
        while dataModel.changes.count > 0 {
            let changedDate = dataModel.changes.removeFirst()
            let components = Calendar.current.dateComponents([.day, .month, .year], from: changedDate)
            print("    Components: \(components)")
            allComponents.append(components)
        }
        print("All components: \(allComponents)")
        uiView.reloadDecorations(forDateComponents: allComponents, animated: true)
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
            
            let antiCoagulantDose = self.parent.dataModel.allAntiCoagulantDoses().first(where: { $0.timestamp?.startOfDay == dateComponents.date?.startOfDay })
            
            let font = UIFont.systemFont(ofSize: 12)
            let configuration = UIImage.SymbolConfiguration(font: font)
                        
            if antiCoagulantDose == nil {
                let image = UIImage(systemName: "exclamationmark.triangle", withConfiguration: configuration)?
                    .withRenderingMode(.alwaysOriginal)
                    .withTintColor(.red)
                
                return .image(image)
            }
            
            return .customView {
                let label = UILabel()
                label.text = "\(antiCoagulantDose!.dose)g"
                label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
                return label
            }
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

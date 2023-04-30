//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by Finn LeSueur on 3/04/23.
//

import WidgetKit
import SwiftUI

@main
struct WidgetsBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        WidgetChart()
        WidgetStatus()
    }
}

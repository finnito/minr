//
//  File.swift
//  mInr
//
//  Created by Finn LeSueur on 15/12/23.
//

import SwiftUI
import TipKit

//struct TIPTemplate: Tip {
//    var title: Text {
//        Text("")
//    }
//    var message: Text? {
//        Text("")
//    }
//    var image: Image? {
//        Image(systemName: K.SFSymbols.tip)
//    }
//}

struct TIPSettings: Tip {
    var title: Text {
        Text("Adjust Your Settings")
    }
    var message: Text? {
        Text("Change medication name, INR range, medication reminders and more.")
    }
    var image: Image? {
        Image(systemName: K.SFSymbols.tip)
    }
}

struct TIPHelp: Tip {
    var title: Text {
        Text("Get Help")
    }
    var message: Text? {
        Text("See instructions & videos on how to use the app. Email for help.")
    }
    var image: Image? {
        Image(systemName: K.SFSymbols.tip)
    }
}

//
//  StoreView.swift
//  mInr
//
//  Created by Finn LeSueur on 30/04/23.
//  Source: https://www.revenuecat.com/blog/engineering/ios-in-app-subscription-tutorial-with-storekit-2-and-swift/
//

import SwiftUI
import StoreKit

struct StoreView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    
    var body: some View {
        VStack {
            Text("This app is free but please consider supporting the work I put into it buy purchasing one of the following. Each tip can be purchased multiple times.")
                .padding(10)
            HStack(spacing: 40) {
                ForEach(purchaseManager.products) { product in
                    Button {
                        _ = Task {
                            do {
                                try await purchaseManager.purchase(product)
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        Text("\(product.displayName)\n\(product.displayPrice)")
                    }.buttonStyle(.bordered)
                }
            }
            .padding(.vertical, 10)
        }
        .task {
            do {
                try await purchaseManager.loadProducts()
            } catch {
                print(error)
            }
        }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
            .environmentObject(PurchaseManager())
    }
}

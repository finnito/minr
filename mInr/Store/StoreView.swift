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
    @Environment(\.colorScheme) var colorScheme
//    let productIds = ["tip_coffee", "tip_drink", "tip_dinner"]
//    @State private var products: [Product] = []
//    private var taskHandle
    
//    init() {
//        taskHandle = listenForTransactions()
//    }
    
    var body: some View {
        VStack {
            Text("Support The App").sectionHeaderStyle()
                .padding(.horizontal, 5)
            VStack() {
                Text("This app is free but please consider supporting the work I put into it buy purchasing one of the following. They can be purchased multiple times.")
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
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? .white.opacity(0.1) : .white)
                    .shadow(
                        color: Color.gray.opacity(0.25),
                        radius: 10,
                        x: 0,
                        y: 0
                    )
            )
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

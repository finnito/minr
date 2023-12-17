//
//  PurchaseManager.swift
//  mInr
//
//  Created by Finn LeSueur on 30/04/23.
//  Source: https://github.com/RevenueCat/storekit2-demo-app/blob/main/StepByStepExamples/Step4/Shared/PurchaseManager.swift
//

import Foundation
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {

    private let productIds = ["tip_coffee", "tip_drink", "tip_dinner"]

    @Published
    private(set) var products: [Product] = []
    @Published
    private(set) var purchasedProductIDs = Set<String>()

    private var productsLoaded = false
    private var updates: Task<Void, Never>? = nil

    init() {
        self.updates = observeTransactionUpdates()
    }

    deinit {
        self.updates?.cancel()
    }

    var hasUnlockedPro: Bool {
       return !self.purchasedProductIDs.isEmpty
    }

    func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIds)
        self.productsLoaded = true
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            // Successful purchase
            await transaction.finish()
            await self.updatePurchasedProducts()
        case .success(.unverified(_, _)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            // ^^^
            break
        @unknown default:
            break
        }
    }

    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await _ in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.updatePurchasedProducts()
            }
        }
    }
}

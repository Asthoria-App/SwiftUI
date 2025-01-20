//
//  PaymentManager.swift
//  test_purchases
//
//  Created by Aysema Çam on 20.01.2025.
//

import Combine
import Foundation
import RevenueCat

class PaymentManager: ObservableObject {
    @Published var availableProducts: [StoreProduct] = []
    @Published var isConfigured: Bool = false

    func initializeRevenueCat() {
        print("Initializing RevenueCat...")
        Purchases.shared.getCustomerInfo { customerInfo, error in
            if let error = error {
                print("Error initializing RevenueCat: \(error.localizedDescription)")
                self.isConfigured = false
            } else {
                print("RevenueCat configured successfully.")
                self.isConfigured = true
                self.fetchProducts()
            }
        }
    }

    func fetchProducts() {
        print("Fetching products...")
        let productIdentifiers = [
            "test_revenucat_1",
            "test_revenucat_2",
            "com.aysemacam.coins.50"
        ]

        Purchases.shared.getProducts(productIdentifiers) { products in
            DispatchQueue.main.async {
                self.availableProducts = products
                print("Products fetched: \(products.map { $0.localizedTitle })")
            }
        }
    }

    func purchase(product: StoreProduct) {
        print("🛒 Attempting to purchase \(product.localizedTitle)...")
        Purchases.shared.purchase(product: product) { transaction, customerInfo, error, userCancelled in
            if let error = error {
                print("Purchase failed: \(error.localizedDescription)")
            } else if userCancelled {
                print("Purchase cancelled by user.")
            } else {
                print("Purchase successful for \(product.localizedTitle)!")
                self.handleSuccessfulPurchase(product)
            }
        }
    }

    private func handleSuccessfulPurchase(_ product: StoreProduct) {
        DispatchQueue.main.async {
            print("Successfully purchased \(product.localizedTitle)!")
        }
    }
}

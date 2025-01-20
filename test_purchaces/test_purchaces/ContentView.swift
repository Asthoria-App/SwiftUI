//
//  ContentView.swift
//  test_purchases
//
//  Created by Aysema Çam on 20.01.2025.
//

import SwiftUI
import RevenueCat

import SwiftUI

struct ContentView: View {
    @StateObject private var paymentManager = PaymentManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("buy for once")
                .font(.largeTitle)
                .padding()

            if paymentManager.isConfigured {
                ForEach(paymentManager.availableProducts, id: \.productIdentifier) { product in
                    Button(action: {
                        paymentManager.purchase(product: product)
                    }) {
                        Text("Buy: \(product.localizedTitle) - \(product.localizedPriceString)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                Text("⚠️ RevenueCat henüz yapılandırılmadı.")
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .onAppear {
            paymentManager.initializeRevenueCat()
        }
    }
}


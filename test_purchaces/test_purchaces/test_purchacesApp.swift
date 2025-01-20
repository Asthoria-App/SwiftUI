//
//  test_purchacesApp.swift
//  test_purchaces
//
//  Created by Aysema Çam on 20.01.2025.
//

import SwiftUI
import RevenueCat

@main
struct MyApp: App {
    init() {
        Purchases.configure(withAPIKey: "appl_jlkQwvXGhRtdxPkOynGyHpPQwYF")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

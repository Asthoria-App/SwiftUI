//
//  Meditation.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 6.08.2024.
//

import Foundation

struct Meditation: Identifiable {
    let id = UUID()
    let title: String
    let image: String
    let icon: String
    let description: String
    let isPremium: Bool
}

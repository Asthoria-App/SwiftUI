//
//  ContentView.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 6.08.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showDetailView = false
    let categories = [
        (title: "Sleep Meditations", icon: "icon1"),
        (title: "Relaxation", icon: "icon2"),
        (title: "Focus", icon: "icon3"),
        (title: "Stress Relief", icon: "icon4"),
        (title: "Mindfulness", icon: "icon5")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    TopPart()
                        .frame(height: 80)
                    
                    CategoriesCollectionView(categories: categories)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    CategorySection(title: "Sleep Meditations", meditations: sampleMeditations, showDetailView: $showDetailView)
                    CategorySection(title: "Relaxation", meditations: sampleMeditations, showDetailView: $showDetailView)
                    CategorySection(title: "Focus", meditations: sampleMeditations2, showDetailView: $showDetailView)
                    CategorySection(title: "Stress Relief", meditations: sampleMeditations, showDetailView: $showDetailView)
                    CategorySection(title: "Mindfulness", meditations: sampleMeditations, showDetailView: $showDetailView)
                }
            }
            .background(Color.black)
            .navigationBarTitle(" ", displayMode: .inline)
        }
    }
}



#Preview {
    ContentView()
}

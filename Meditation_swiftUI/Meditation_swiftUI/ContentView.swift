//
//  ContentView.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 6.08.2024.
//

import SwiftUI


// Preview
struct ContentView: View {
    let categories = [
        (title: "Sleep Meditations", icon: "icon1"),
        (title: "Relaxation", icon: "icon2"),
        (title: "Focus", icon: "icon3"),
        (title: "Stress Relief", icon: "icon4"),
        (title: "Mindfulness", icon: "icon5")
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                TopPart()
                    .frame(height: 80)
                
                CategoriesCollectionView(categories: categories)
                    .padding(.horizontal)
                    .padding(.top)
                
                CategorySection(title: "Sleep Meditations", meditations: sampleMeditations)
                CategorySection(title: "Relaxation", meditations: sampleMeditations)
                CategorySection(title: "Focus", meditations: sampleMeditations2)
                CategorySection(title: "Stress Relief", meditations: sampleMeditations)
                CategorySection(title: "Mindfulness", meditations: sampleMeditations)
            }
        }
        .background(Color.black)
    }
}



#Preview {
    ContentView()
}

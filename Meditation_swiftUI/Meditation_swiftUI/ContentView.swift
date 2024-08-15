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
        (title: "Stress Relief", icon: "icon4"),
        (title: "Stress Relief", icon: "icon4"),
        (title: "Stress Relief", icon: "icon4"),
        (title: "Stress Relief", icon: "icon4"),
        (title: "Mindfulness", icon: "icon5")
        
    ]
    let layout = [
        GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
//                    
//                LazyVGrid(columns: layout, spacing: 20) {
//                    ForEach(categories, id: \.title) { item in
//                        
//                        VStack {
////                            Capsule()
////                                .fill(Color.red)
////                                .frame(height: 20)
//                                                CategoriesCollectionView(categories: categories)
//                                                    .padding(.horizontal)
//                                                    .padding(.top)
//                                                CategorySection(title: "Sleep Meditations", meditations: sampleMeditations, showDetailView: $showDetailView)
//
//                            
//                            
//                        }
//                    }
//                }
//                    
                    TopPart()
                        .frame(height: 80)
                   
                    
                    CategoriesCollectionView(categories: categories)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    CategorySection(title: "Sleep Meditations", meditations: sampleMeditations, showDetailView: $showDetailView)
                    CategorySection(title: "Relaxation Sound", meditations: sampleMeditations, showDetailView: $showDetailView)
                    CategorySection(title: "Focus On", meditations: sampleMeditations2, showDetailView: $showDetailView)
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

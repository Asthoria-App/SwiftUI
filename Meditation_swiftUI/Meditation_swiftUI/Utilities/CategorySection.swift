//
//  CategorySection.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 6.08.2024.
//

import SwiftUI

// Model
struct Meditation: Identifiable {
    let id = UUID()
    let title: String
    let image: String
    let icon: String
    let description: String
    let isPremium: Bool
}

// Sample Data
let sampleMeditations = [
    Meditation(title: "Relaxing Sounds", image: "image1", icon: "icon1", description: "Relax with calming sounds.", isPremium: false),
    Meditation(title: "Deep Sleep", image: "image2", icon: "icon2", description: "Fall into a deep sleep.", isPremium: true),
    Meditation(title: "Stress Relief", image: "image3", icon: "icon3", description: "Relieve your stress.", isPremium: false),
    Meditation(title: "Mindfulness", image: "image4", icon: "icon4", description: "Be present in the moment.", isPremium: true)
]
let sampleMeditations2 = [
    Meditation(title: "Relaxing Sounds", image: "image6", icon: "icon1", description: "Relax with calming sounds.", isPremium: false),
    Meditation(title: "Deep Sleep", image: "image7", icon: "icon2", description: "Fall into a deep sleep.", isPremium: true),
    Meditation(title: "Stress Relief", image: "image8", icon: "icon3", description: "Relieve your stress.", isPremium: false),
    Meditation(title: "Mindfulness", image: "image9", icon: "icon4", description: "Be present in the moment.", isPremium: true)
]

struct MeditationCell: View {
    let meditation: Meditation
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(meditation.image)
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 170)
                .clipped()
                .background(Color.black)
                .cornerRadius(10)
                .opacity(0.7)
            
            VStack {
                HStack {
                    Image(meditation.icon)
                        .padding(8)
                    Text(meditation.title)
                        .padding(0)
                        .foregroundColor(.white)
                        .font(.footnote)
                        .fontWeight(.bold)
                    Spacer()
                    if meditation.isPremium {
                        Image(systemName: "lock.fill")
                            .padding(.trailing ,8)
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                Text(meditation.description)
                    .foregroundColor(.white)
                    .padding(.bottom)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                    .frame(width: 120)
            }
            .padding(.top)
        }
        .frame(width: 140, height: 170)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Horizontal Collection View
struct MeditationCollectionView: View {
    let meditations: [Meditation]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(meditations) { meditation in
                    MeditationCell(meditation: meditation)
                        .padding(.trailing, 8)
                }
            }
        }
    }
}

// Category Cell
struct CategoryCell: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(icon)
                .resizable()
                .frame(width: 40, height: 40)
            Text(title)
                .foregroundColor(.white)
                .font(.headline)
                .padding(.leading, 5)
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .frame(width: 150, height: 60)
    }
}

// Categories Collection View
struct CategoriesCollectionView: View {
    let categories: [(title: String, icon: String)]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(categories, id: \.title) { category in
                    CategoryCell(title: category.title, icon: category.icon)
                        .padding(.trailing, 8)
                }
            }
        }
    }
}

// Category Section View
struct CategorySection: View {
    var title: String
    var meditations: [Meditation]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    // See All Action
                }) {
                    Text("See all")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            MeditationCollectionView(meditations: meditations)
                .padding(.horizontal)
        }
        .padding(.top)
    }
}



// Preview
struct ContentVview: View {
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
                
                // Categories Collection View
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
    ContentVview()
}

//
//  CategorySection.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 6.08.2024.
//

import SwiftUI



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

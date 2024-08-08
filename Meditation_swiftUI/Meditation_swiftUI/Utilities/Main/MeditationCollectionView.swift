//
//  MeditationCollectionView.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 6.08.2024.
//

import SwiftUI

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

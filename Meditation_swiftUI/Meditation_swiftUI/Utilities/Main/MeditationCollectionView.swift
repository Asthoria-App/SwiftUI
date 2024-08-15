//
//  MeditationCollectionView.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 6.08.2024.
//

import SwiftUI

struct MeditationCollectionView: View {
    let meditations: [Meditation]
    @Binding var showDetailView: Bool
    @Binding var selectedMeditation: Meditation?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(meditations) { meditation in
                    MeditationCell(meditation: meditation)
                        .padding(.trailing, 8)
                        .onTapGesture {
                            selectedMeditation = meditation
                            showDetailView = true
                            
                        }
                }
            }
        }
    }
}

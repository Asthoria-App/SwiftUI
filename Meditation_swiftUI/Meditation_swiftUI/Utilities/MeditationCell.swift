//
//  MeditationCell.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 6.08.2024.
//

import SwiftUI

struct MeditationCell: View {
    let meditation: Meditation
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(meditation.image)
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 170)
//                .clipped()
                .background(Color.black)
                .cornerRadius(10)
                .opacity(0.7)
            
            VStack {
                HStack {
                    Image(meditation.icon)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 20, height: 20)
                        .padding(.leading, 8)
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


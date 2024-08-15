//
//  PlayerView.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 8.08.2024.
//

import SwiftUI
import Lottie

struct PlayerView: View {
    let meditation: Meditation
    @State private var progressValue: Double = 0.5
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LottieView(filename: "stars_top")
                    .frame(width: geometry.size.width, height: geometry.size.height * 3)
                    .offset(y: geometry.size.height * 0.01)
                    .clipped()
                    .opacity(0.9)
                
                Color.black.opacity(0.3)
                    .frame(width: geometry.size.width, height: geometry.size.height * 1.1)
                
                VStack(spacing: 20) {
                    Image(meditation.image)
                        .resizable()
                        .opacity(0.9)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 220)
                        .cornerRadius(20)
                        .clipped()

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(meditation.title)
                                .font(.title)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "heart.fill")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        
                        Text(meditation.description)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                    }
                    
                    Button(action: {
                        // Play button action
                    }) {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 60, height: 60)
                    }
                    .frame(width: geometry.size.width, alignment: .center)
                    
                    ProgressView(value: progressValue)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white.opacity(0.8)))
                        .bold()
                        .frame(width: geometry.size.width * 0.9, height: 30)
                        .padding(.horizontal, 20)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                
                VStack {
                    HStack {
                        Spacer()
                        Spacer()
                    }
                    Spacer()
                }
                
                .padding(.leading, 16)
                .padding(.top, 16)
                
                VStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .resizable()
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 25, height:25)
                                .padding()
                                .cornerRadius(10)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top ,850)
                .padding(.leading, 10)
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height * 1.1)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}

//#Preview {
//    PlayerView(meditation: Meditation(title: "Sample Title", image: "image9", icon: "iconName", description: "Sample Description", isPremium: false))
//}

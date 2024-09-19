//
//  SoundSelectionView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 19.09.2024.
//

import SwiftUI

struct SoundSelectionView: View {
    @Binding var isShowing: Bool
    @Binding var selectedSound: URL?
    var stopCurrentMusic: () -> Void
    let soundFiles = ["audio1", "audio2", "audio3", "audio4"]
    let fileExtension = "mp3"
    
    var body: some View {
        VStack {
            Text("Select Background Music")
                .font(.headline)
                .padding()
            
            ScrollView {
                Button(action: {
                    selectedSound = nil
                    stopCurrentMusic()
                    isShowing = false
                }) {
                    Text("No Music")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                ForEach(soundFiles, id: \.self) { sound in
                    Button(action: {
                        if let url = Bundle.main.url(forResource: sound, withExtension: fileExtension) {
                            selectedSound = url
                        }
                        isShowing = false
                    }) {
                        Text(sound.capitalized)
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
            }
            
            Button(action: {
                isShowing = false
            }) {
                Text("Cancel")
                    .font(.title3)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .background(Color.black)
        .cornerRadius(20)
        .padding()
        .shadow(radius: 10)
    }
}





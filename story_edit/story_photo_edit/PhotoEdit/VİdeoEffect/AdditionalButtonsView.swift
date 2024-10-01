//
//  AdditionalButtonsView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 19.09.2024.
//

import SwiftUI
import AVKit

struct AdditionalButtonsView: View {
    var addTimeImage: () -> Void
    var addLocationImage: () -> Void
    
    @Binding var showTagOverlay: Bool
    @Binding var isMuted: Bool
    @State private var showMusicSelectionOverlay: Bool = false
    @Binding var selectedSoundURL: URL?
    @Binding var isPlaying: Bool
    
    @State private var audioPlayer: AVPlayer?
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                showTagOverlay = true
            }) {
                Image(systemName: "tag")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .padding(10)
            }
            .shadow(color: .gray.opacity(0.8), radius: 5, x: 0, y: 5)
            
            Button(action: {
                addTimeImage()
            }) {
                Image(systemName: "clock")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .padding(10)
            }
            .shadow(color: .gray.opacity(0.8), radius: 5, x: 0, y: 5)
            
            Button(action: {
                addLocationImage()
            }) {
                Image(systemName: "location")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .padding(10)
            }
            .shadow(color: .gray.opacity(0.8), radius: 5, x: 0, y: 5)
            
            Button(action: {
                if selectedSoundURL == nil {
                    isMuted.toggle()
                }            }) {
                    Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .padding(10)
                }
                .shadow(color: .gray.opacity(0.8), radius: 5, x: 0, y: 5)
            
            Button(action: {
                showMusicSelectionOverlay = true
            }) {
                Image(systemName: "music.note.list")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .padding(10)
            }
            .shadow(color: .gray.opacity(0.8), radius: 5, x: 0, y: 5)
        }
        .sheet(isPresented: $showMusicSelectionOverlay) {
            SoundSelectionView(isShowing: $showMusicSelectionOverlay, selectedSound: $selectedSoundURL, stopCurrentMusic: {
                audioPlayer?.pause()
                audioPlayer = nil
            })
            
        }
        .onChange(of: selectedSoundURL) { newSoundURL in
            if let soundURL = newSoundURL {
                playSelectedMusic(soundURL: soundURL)
                isMuted = true
            }
        }
        .onChange(of: isPlaying) {  newValue in
            if newValue == true {
                audioPlayer?.play()
            } else {
                audioPlayer?.pause()
                audioPlayer = nil
            }
        }
    }
    
    
    
    
    private func playSelectedMusic(soundURL: URL) {
        if let player = audioPlayer {
            player.pause()
        }
        
        audioPlayer = AVPlayer(url: soundURL)
        audioPlayer?.isMuted = false
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: audioPlayer?.currentItem, queue: .main) { _ in
            self.audioPlayer?.seek(to: .zero)
            self.audioPlayer?.play()
        }
        if isPlaying {
            audioPlayer?.play()
        } else {
            audioPlayer?.pause()
            audioPlayer = nil
        }
    }
}




























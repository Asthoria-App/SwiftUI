//
//  FullScreenVideoPlayerView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 19.09.2024.
//

import AVKit
import SwiftUI

struct FullScreenVideoPlayerView: View {
    var videoURL: URL
    
    @State private var player = AVPlayer()
    @Binding var selectedEffect: EffectType?
    @Binding var hideButtons: Bool
    @Binding var isMUted: Bool
    @Binding var isPlaying: Bool  
    
    var body: some View {
        VStack {
            VideoPlayerContainer(player: player, selectedEffect: $selectedEffect)
                .onAppear {
                    setupPlayer()
                    if isPlaying {
                        player.play()
                    }
                }
                .onDisappear {
                    player.pause()
                    NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
                }
                .onChange(of: isMUted) { newValue in
                    player.isMuted = newValue
                }
                .onChange(of: isPlaying) { newValue in
                    if newValue {
                        player.play()
                    } else {
                        player.pause()
                    }
                }
                .edgesIgnoringSafeArea(.all)
            
            if !hideButtons {
                EffectSelectionView(selectedEffect: $selectedEffect)
                    .frame(height: 100)
            }
        }
    }
    
    private func setupPlayer() {
        let playerItem = AVPlayerItem(url: videoURL)
        player.replaceCurrentItem(with: playerItem)
        player.isMuted = isMUted
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            if isPlaying {
                player.play()
            }
        }
    }
}

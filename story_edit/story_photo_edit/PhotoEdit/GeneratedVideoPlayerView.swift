//
//  GeneratedVideoPlayerView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 19.09.2024.
//

import SwiftUI
import AVKit

struct GeneratedVideoPlayerView: UIViewControllerRepresentable {
    var videoURL: URL
    var tagPositions: [(position: CGPoint, index: Int)]
    var locationPositions: [(position: CGPoint, index: Int)]
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        let player = AVPlayer(url: videoURL)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
               
                    print(tagPositions, locationPositions, "positions")
                
        }
        
        playerViewController.player = player
        playerViewController.videoGravity = .resizeAspectFill
        
        playerViewController.showsPlaybackControls = false
        player.play()
        return playerViewController
    }
    
    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
    }
    
    static func dismantleUIViewController(_ playerViewController: AVPlayerViewController, coordinator: ()) {
        NotificationCenter.default.removeObserver(playerViewController, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}

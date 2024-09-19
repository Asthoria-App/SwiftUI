//
//  SimpleVideoPlayerView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 19.09.2024.
//

import SwiftUI
import AVKit

struct SimpleVideoPlayerView: UIViewControllerRepresentable {
    var videoURL: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        let player = AVPlayer(url: videoURL)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
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

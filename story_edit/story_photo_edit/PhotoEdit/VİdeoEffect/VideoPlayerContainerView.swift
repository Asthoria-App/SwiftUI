//
//  VideoPlayerContainerView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 19.09.2024.
//

import SwiftUI
import AVFoundation

 public struct VideoPlayerContainer: UIViewControllerRepresentable {
    var player: AVPlayer
    
    @Binding var selectedEffect: EffectType?
    
     public func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = UIScreen.main.bounds
        
        let containerView = UIView(frame: UIScreen.main.bounds)
        containerView.layer.addSublayer(playerLayer)
        
        controller.view = containerView
        return controller
    }
    
     public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let playerLayer = uiViewController.view.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = UIScreen.main.bounds
        }
        
        uiViewController.view.subviews.forEach { $0.removeFromSuperview() }
        
        if let selectedEffect = selectedEffect {
            switch selectedEffect {
            case .color(let color):
                resetVideoCompositionIfNeeded()
  
                
                let overlayView = UIView(frame: UIScreen.main.bounds)
                overlayView.backgroundColor = UIColor(color)
                overlayView.alpha = 0.1
                uiViewController.view.addSubview(overlayView)
     
                
            case .monochrome:
                if let currentPlayerItem = player.currentItem {
                    let filter = CIFilter(name: "CIColorMonochrome")
                    filter?.setValue(CIColor(color: .white), forKey: kCIInputColorKey)
                    filter?.setValue(1.0, forKey: kCIInputIntensityKey)
                    
                    let videoComposition = AVVideoComposition(asset: currentPlayerItem.asset) { request in
                        let source = request.sourceImage.clampedToExtent()
                        filter?.setValue(source, forKey: kCIInputImageKey)
                        
                        if let output = filter?.outputImage {
                            let croppedOutput = output.cropped(to: request.sourceImage.extent)
                            request.finish(with: croppedOutput, context: nil)
                        } else {
                            request.finish(with: request.sourceImage, context: nil)
                        }
                    }
                    currentPlayerItem.videoComposition = videoComposition
                }
            }
        }
    }
    
    private func resetVideoCompositionIfNeeded() {
        if let currentPlayerItem = player.currentItem {
            currentPlayerItem.videoComposition = nil
            player.play()
        }
    }
}



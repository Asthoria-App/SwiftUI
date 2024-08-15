import AVFoundation
import CoreImage
import SwiftUI

public class VideoProcessor: ObservableObject {
    private let videoURL: URL
    private var speed: Float = 1.0
    private var selectedFilter: VideoFilter?

    public init(videoURL: URL) {
        self.videoURL = videoURL
    }

    // Set video speed
    public func setVideo(speed: Float = 1.0) {
        self.speed = speed
    }

    // Set the video filter
    public func setFilter(_ filter: VideoFilter) {
        self.selectedFilter = filter
    }

    // Process video with optional boomerang effect
    public func processVideo(applyBoomerang: Bool, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: videoURL)
        let composition = AVMutableComposition()

        Task {
            do {
                let videoTrack = try await asset.loadTracks(withMediaType: .video).first
                let duration = try await asset.load(.duration)

                guard let videoTrack = videoTrack else {
                    completion(nil)
                    return
                }

                // Step 1: Create the initial composition
                let videoComposition = try createBoomerangComposition(for: videoTrack, duration: duration, in: composition, applyBoomerang: applyBoomerang)

                // Step 2: Apply filter if any
                if let filter = self.selectedFilter?.filter {
                    applyCIFilter(filter, to: videoComposition, using: composition, completion: completion)
                } else {
                    export(composition: composition, videoComposition: videoComposition, completion: completion)
                }
            } catch {
                completion(nil)
            }
        }
    }

    // Create boomerang composition
    private func createBoomerangComposition(for videoTrack: AVAssetTrack, duration: CMTime, in composition: AVMutableComposition, applyBoomerang: Bool) throws -> AVMutableVideoComposition {
        let videoComposition = AVMutableVideoComposition()
        let timeRange = CMTimeRange(start: .zero, duration: duration)

        // Add the forward video track
        let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        try videoCompositionTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)
        videoCompositionTrack.scaleTimeRange(timeRange, toDuration: CMTimeMultiplyByFloat64(duration, multiplier: 1.0 / Double(speed)))

        // Handle boomerang
        if applyBoomerang {
            // Reverse the video and append
            let reversedTrack = try reverseVideoTrack(for: videoTrack, in: composition, duration: duration)
            
            let forwardInstruction = AVMutableVideoCompositionInstruction()
            forwardInstruction.timeRange = CMTimeRange(start: .zero, duration: duration)
            forwardInstruction.layerInstructions = [AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)]

            let reverseInstruction = AVMutableVideoCompositionInstruction()
            reverseInstruction.timeRange = CMTimeRange(start: duration, duration: duration)
            reverseInstruction.layerInstructions = [AVMutableVideoCompositionLayerInstruction(assetTrack: reversedTrack)]

            videoComposition.instructions = [forwardInstruction, reverseInstruction]
        } else {
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: .zero, duration: duration)
            instruction.layerInstructions = [AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)]
            videoComposition.instructions = [instruction]
        }

        videoComposition.renderSize = videoTrack.naturalSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        return videoComposition
    }

    // Reverse video track
    private func reverseVideoTrack(for videoTrack: AVAssetTrack, in composition: AVMutableComposition, duration: CMTime) throws -> AVMutableCompositionTrack {
        let reversedTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!

        // Insert reversed frames
        let timeRange = CMTimeRange(start: .zero, duration: duration)
        try reversedTrack.insertTimeRange(timeRange, of: videoTrack, at: duration)

        return reversedTrack
    }

    // Apply CIFilter to video
    private func applyCIFilter(_ filter: CIFilter, to videoComposition: AVMutableVideoComposition, using composition: AVMutableComposition, completion: @escaping (URL?) -> Void) {
        let videoCompositionWithFilter = AVVideoComposition(asset: composition) { request in
            let source = request.sourceImage.clampedToExtent()
            filter.setValue(source, forKey: kCIInputImageKey)
            let output = filter.outputImage?.cropped(to: request.sourceImage.extent)
            request.finish(with: output ?? source, context: nil)
        }

        export(composition: composition, videoComposition: videoCompositionWithFilter, completion: completion)
    }

    // Export the video to a file
    private func export(composition: AVMutableComposition, videoComposition: AVVideoComposition? = nil, completion: @escaping (URL?) -> Void) {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }

        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition

        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                completion(outputURL)
            } else {
                completion(nil)
            }
        }
    }
}

public enum VideoFilter {
    case sepia, noir, invert, posterize, vignette, comic, blur, monochrome
    
    var filter: CIFilter? {
        switch self {
        case .sepia:
            let filter = CIFilter(name: "CISepiaTone")!
            filter.setValue(1.0, forKey: kCIInputIntensityKey)
            return filter
        case .noir:
            return CIFilter(name: "CIPhotoEffectNoir")!
        case .invert:
            return CIFilter(name: "CIColorInvert")!
        case .posterize:
            let filter = CIFilter(name: "CIColorPosterize")!
            filter.setValue(6.0, forKey: "inputLevels")
            return filter
        case .vignette:
            let filter = CIFilter(name: "CIVignette")!
            filter.setValue(2.0, forKey: kCIInputIntensityKey)
            filter.setValue(30.0, forKey: kCIInputRadiusKey)
            return filter
        case .comic:
            return CIFilter(name: "CIComicEffect")!
        case .blur:
            let filter = CIFilter(name: "CIGaussianBlur")!
            filter.setValue(5.0, forKey: kCIInputRadiusKey)
            return filter
        case .monochrome:
            let filter = CIFilter(name: "CIColorMonochrome")!
            filter.setValue(CIColor(color: .white), forKey: kCIInputColorKey)
            filter.setValue(1.0, forKey: kCIInputIntensityKey)
            return filter
        }
    }
}



//public struct VideoPlayerWithOverlay: UIViewControllerRepresentable {
//    public let videoURL: URL
//    public let overlayColor: UIColor
//    public let overlayAlpha: CGFloat
//
//    public init(videoURL: URL, overlayColor: UIColor, overlayAlpha: CGFloat) {
//        self.videoURL = videoURL
//        self.overlayColor = overlayColor
//        self.overlayAlpha = overlayAlpha
//    }
//
//    public func makeUIViewController(context: Context) -> AVPlayerViewController {
//        let playerViewController = AVPlayerViewController()
//        let player = AVPlayer(url: videoURL)
//        playerViewController.player = player
//
//        let overlayManager = VideoOverlayManager()
//        let overlayView = overlayManager.createOverlayView(frame: playerViewController.view.bounds, color: overlayColor, alpha: overlayAlpha)
//
//        playerViewController.contentOverlayView?.addSubview(overlayView)
//        return playerViewController
//    }
//
//    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
//        // Update the overlay color and alpha dynamically
//        if let overlayView = uiViewController.contentOverlayView?.subviews.first {
//            overlayView.backgroundColor = overlayColor.withAlphaComponent(overlayAlpha)
//        }
//    }
//}
//
//
//public class VideoProcessor: ObservableObject {
//    private let videoURL: URL
//    private var speed: Float = 1.0
//    private var makeBoomerang: Bool = false
//    private var overlayColor: UIColor = .clear
//    private var overlayAlpha: CGFloat = 0.0
//    
//    public init(videoURL: URL) {
//        self.videoURL = videoURL
//    }
//    
//    public func setVideo(speed: Float = 1.0, makeBoomerang: Bool = false) {
//        self.speed = speed
//        self.makeBoomerang = makeBoomerang
//    }
//    
//    public func setOverlayColor(color: UIColor, alpha: CGFloat) {
//        self.overlayColor = color
//        self.overlayAlpha = alpha
//    }
//    
//    public func processVideo(completion: @escaping (URL?) -> Void) {
//        let asset = AVAsset(url: videoURL)
//        let composition = AVMutableComposition()
//        
//        Task {
//            do {
//                let duration = try await asset.load(.duration)
//                
//                let tracks = try await asset.loadTracks(withMediaType: .video)
//                guard let videoTrack = tracks.first else {
//                    completion(nil)
//                    return
//                }
//                
//                try self.processVideoTrack(videoTrack, duration: duration, composition: composition, completion: completion)
//                
//            } catch {
//                print("Error loading asset: \(error.localizedDescription)")
//                completion(nil)
//            }
//        }
//    }
//    
//    private func processVideoTrack(_ videoTrack: AVAssetTrack, duration: CMTime, composition: AVMutableComposition, completion: @escaping (URL?) -> Void) throws {
//        let timeRange = CMTimeRange(start: .zero, duration: duration)
//        let scaledDuration = CMTimeMultiplyByFloat64(duration, multiplier: 1.0 / Float64(self.speed))
//        
//        // İleri oynatma
//        let forwardTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
//        try forwardTrack?.insertTimeRange(timeRange, of: videoTrack, at: .zero)
//        forwardTrack?.scaleTimeRange(timeRange, toDuration: scaledDuration)
//        print("Forward track inserted: \(timeRange)")
//        
//        if self.makeBoomerang {
//            let reverseTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
//            
//            let frameDuration = CMTime(seconds: 1.0 / Double(videoTrack.nominalFrameRate), preferredTimescale: videoTrack.naturalTimeScale)
//            let frameCount = Int(duration.seconds * Double(videoTrack.nominalFrameRate))
//            
//            for i in (0..<frameCount).reversed() {
//                let currentFrameTime = CMTime(seconds: Double(i) / Double(videoTrack.nominalFrameRate), preferredTimescale: videoTrack.naturalTimeScale)
//                let frameTimeRange = CMTimeRange(start: currentFrameTime, duration: frameDuration)
//                
//                do {
//                    try reverseTrack?.insertTimeRange(frameTimeRange, of: videoTrack, at: reverseTrack?.timeRange.duration ?? .zero)
//                    print("Inserted reverse frame: \(frameTimeRange) at \(reverseTrack?.timeRange.duration ?? .zero)")
//                } catch {
//                    print("Error inserting reverse frame: \(error)")
//                    completion(nil)
//                    return
//                }
//            }
//            
//            let reverseTimeRange = CMTimeRange(start: .zero, duration: reverseTrack?.timeRange.duration ?? .zero)
//            do {
//                try reverseTrack?.scaleTimeRange(reverseTimeRange, toDuration: scaledDuration)
//                try forwardTrack?.insertTimeRange(reverseTimeRange, of: reverseTrack!, at: scaledDuration)
//                print("Reverse track added at duration: \(scaledDuration.seconds)")
//            } catch {
//                print("Error adding reverse track to composition: \(error)")
//                completion(nil)
//                return
//            }
//        }
//        
//        self.export(composition: composition, outputFileName: "processed_video.mov", completion: completion)
//    }
//    
//    private func export(composition: AVMutableComposition, outputFileName: String, completion: @escaping (URL?) -> Void) {
//        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
//
//        if FileManager.default.fileExists(atPath: outputURL.path) {
//            do {
//                try FileManager.default.removeItem(at: outputURL)
//            } catch {
//                print("Failed to remove existing file: \(error)")
//                completion(nil)
//                return
//            }
//        }
//
//        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
//            completion(nil)
//            return
//        }
//
//        exportSession.outputURL = outputURL
//        exportSession.outputFileType = .mov
//
//        exportSession.exportAsynchronously {
//            switch exportSession.status {
//            case .completed:
//                print("Export completed. Output URL: \(outputURL)")
//                completion(outputURL)
//            default:
//                print("Export failed: \(exportSession.error?.localizedDescription ?? "unknown error")")
//                completion(nil)
//            }
//        }
//    }
//}
//
//public class VideoOverlayManager {
//    public init() {}
//    
//    public func createOverlayView(frame: CGRect, color: UIColor, alpha: CGFloat) -> UIView {
//        let overlayView = UIView(frame: frame)
//        overlayView.backgroundColor = color.withAlphaComponent(alpha)
//        return overlayView
//    }
//}

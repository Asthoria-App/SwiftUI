//
//  video_editor_sampleApp.swift
//  video_editor_sample
//
//  Created by Aysema ÇAm on 12.08.2024.
//

import SwiftUI

@main
struct video_editor_sampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
//Category(title: "Flowers", imageName: "camera.macro"),
//Category(title: "Music", imageName: "music.note"),
//Category(title: "Nature", imageName: "tree.fill"),
//Category(title: "Animals", imageName: "cat.fill"),
//Category(title: "Movies", imageName: "movieclapper.fill"),
//Category(title: "Snow", imageName: "snowflake")
//]
//
//private let apiKey = "45070802-922c9dbab911a14e7d81c3b6b"
//
//func fetchVideos(query: String) {
//guard let url = URL(string: "https://pixabay.com/api/videos/?key=\(apiKey)&q=\(query)") else { return }

//import SwiftUI
//
//import AVKit
//
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
//import AVFoundation
//import CoreImage
//
//public class VideoProcessor: ObservableObject {
//    private let videoURL: URL
//    private var speed: Float = 1.0
//    private var makeBoomerang: Bool = false
//    private var overlayColor: UIColor = .clear
//    private var overlayAlpha: CGFloat = 0.0
//    private var isMonochrome: Bool = false
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
//        self.isMonochrome = false
//    }
//    
//    public func setMonochromeFilter() {
//        self.isMonochrome = true
//    }
//    
//    public func processVideo(completion: @escaping (URL?) -> Void) {
//        let asset = AVAsset(url: videoURL)
//        let composition = AVMutableComposition()
//        
//        Task {
//            do {
//                let duration = try await asset.load(.duration)
//                let tracks = try await asset.loadTracks(withMediaType: .video)
//                guard let videoTrack = tracks.first else {
//                    completion(nil)
//                    return
//                }
//                
//                try processVideoTrack(videoTrack, duration: duration, composition: composition, completion: completion)
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
//        let scaledDuration = CMTimeMultiplyByFloat64(duration, multiplier: 1.0 / Float64(speed))
//        
//        // Forward Track
//        let forwardTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
//        try forwardTrack?.insertTimeRange(timeRange, of: videoTrack, at: .zero)
//        forwardTrack?.scaleTimeRange(timeRange, toDuration: scaledDuration)
//        
//        if makeBoomerang {
//            let reverseTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
//            try insertReverseFrames(from: videoTrack, to: reverseTrack, duration: duration)
//            let reverseTimeRange = CMTimeRange(start: .zero, duration: reverseTrack!.timeRange.duration)
//            try reverseTrack?.scaleTimeRange(reverseTimeRange, toDuration: scaledDuration)
//            try forwardTrack?.insertTimeRange(reverseTimeRange, of: reverseTrack!, at: scaledDuration)
//        }
//        
//        if isMonochrome {
//            applyMonochromeFilter(to: composition, completion: completion)
//        } else {
//            applyOverlay(to: composition, completion: completion)
//        }
//    }
//    
//    private func insertReverseFrames(from videoTrack: AVAssetTrack, to reverseTrack: AVMutableCompositionTrack?, duration: CMTime) throws {
//        let frameDuration = CMTime(seconds: 1.0 / Double(videoTrack.nominalFrameRate), preferredTimescale: videoTrack.naturalTimeScale)
//        let frameCount = Int(duration.seconds * Double(videoTrack.nominalFrameRate))
//        
//        for i in (0..<frameCount).reversed() {
//            let currentFrameTime = CMTime(seconds: Double(i) / Double(videoTrack.nominalFrameRate), preferredTimescale: videoTrack.naturalTimeScale)
//            let frameTimeRange = CMTimeRange(start: currentFrameTime, duration: frameDuration)
//            try reverseTrack?.insertTimeRange(frameTimeRange, of: videoTrack, at: reverseTrack?.timeRange.duration ?? .zero)
//        }
//    }
//    
//    private func applyMonochromeFilter(to composition: AVMutableComposition, completion: @escaping (URL?) -> Void) {
//        let filter = CIFilter(name: "CIColorMonochrome")!
//        filter.setValue(CIColor(color: .white), forKey: kCIInputColorKey)
//        filter.setValue(1.0, forKey: kCIInputIntensityKey)
//        
//        applyCIFilter(filter, to: composition, completion: completion)
//    }
//    
//    private func applyOverlay(to composition: AVMutableComposition, completion: @escaping (URL?) -> Void) {
//        export(composition: composition, outputFileName: "processed_video.mov", completion: completion)
//    }
//    
//    private func applyCIFilter(_ filter: CIFilter, to composition: AVMutableComposition, completion: @escaping (URL?) -> Void) {
//        let videoComposition = AVVideoComposition(asset: composition) { request in
//            let source = request.sourceImage.clampedToExtent()
//            filter.setValue(source, forKey: kCIInputImageKey)
//            
//            if let output = filter.outputImage {
//                let cropped = output.cropped(to: request.sourceImage.extent)
//                request.finish(with: cropped, context: nil)
//            } else {
//                request.finish(with: NSError(domain: "VideoProcessor", code: -1, userInfo: nil))
//            }
//        }
//        
//        export(composition: composition, videoComposition: videoComposition, outputFileName: "processed_video.mov", completion: completion)
//    }
//    
//    private func export(composition: AVMutableComposition, videoComposition: AVVideoComposition? = nil, outputFileName: String, completion: @escaping (URL?) -> Void) {
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
//        exportSession.videoComposition = videoComposition
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
//
//import SwiftUI
//import AVFoundation
//import AVKit
//import CoreImage
//
//public class VideoProcessor: ObservableObject {
//    private let videoURL: URL
//    private var speed: Float = 1.0
//    private var makeBoomerang: Bool = false
//    private var selectedFilter: VideoFilter?
//    
//    public init(videoURL: URL) {
//        self.videoURL = videoURL
//        print("VideoProcessor initialized with URL: \(videoURL)")
//    }
//    
//    public func setVideo(speed: Float = 1.0, makeBoomerang: Bool = false) {
//        self.speed = speed
//        self.makeBoomerang = makeBoomerang
//        print("Video settings updated: speed = \(speed), makeBoomerang = \(makeBoomerang)")
//    }
//    
//    public func setFilter(_ filter: VideoFilter) {
//        self.selectedFilter = filter
//        print("Filter set: \(filter)")
//    }
//    
//    public func processVideo(completion: @escaping (URL?) -> Void) {
//        let asset = AVAsset(url: videoURL)
//        let composition = AVMutableComposition()
//        print("Starting video processing...")
//
//        Task {
//            do {
//                print("Loading video tracks...")
//                let videoTrack = try await asset.loadTracks(withMediaType: .video).first
//                let duration = try await asset.load(.duration)
//                
//                guard let videoTrack = videoTrack else {
//                    print("No video track found.")
//                    completion(nil)
//                    return
//                }
//                print("Video track loaded, duration: \(duration.seconds) seconds")
//                
//                // İlk aşamada boomerang kompozisyonunu oluşturuyoruz
//                let videoComposition = try createBoomerangComposition(for: videoTrack, duration: duration, in: composition)
//                
//                // İkinci aşamada CIFilter uygulaması yapılıyor
//                if let filter = self.selectedFilter?.filter {
//                    print("Applying CIFilter...")
//                    applyCIFilter(filter, to: videoComposition, using: composition, completion: completion)
//                } else {
//                    print("No filter applied, exporting...")
//                    export(composition: composition, videoComposition: videoComposition, completion: completion)
//                }
//                
//            } catch {
//                print("Error during video processing: \(error.localizedDescription)")
//                completion(nil)
//            }
//        }
//    }
//    
//    private func createBoomerangComposition(for videoTrack: AVAssetTrack, duration: CMTime, in composition: AVMutableComposition) throws -> AVVideoComposition {
//        print("Creating boomerang composition...")
//        let timeRange = CMTimeRange(start: .zero, duration: duration)
//        let scaledDuration = CMTimeMultiplyByFloat64(duration, multiplier: 1.0 / Float64(self.speed))
//        
//        let forwardTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
//        try forwardTrack?.insertTimeRange(timeRange, of: videoTrack, at: .zero)
//        forwardTrack?.scaleTimeRange(timeRange, toDuration: scaledDuration)
//        print("Forward track inserted and scaled.")
//        
//        if self.makeBoomerang {
//            print("Adding reverse track for boomerang...")
//            let reverseTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
//            let frameDuration = CMTime(seconds: 1.0 / Double(videoTrack.nominalFrameRate), preferredTimescale: videoTrack.naturalTimeScale)
//            let frameCount = Int(duration.seconds * Double(videoTrack.nominalFrameRate))
//            
//            for i in (0..<frameCount).reversed() {
//                let currentFrameTime = CMTime(seconds: Double(i) * frameDuration.seconds, preferredTimescale: videoTrack.naturalTimeScale)
//                let frameTimeRange = CMTimeRange(start: currentFrameTime, duration: frameDuration)
//                try reverseTrack?.insertTimeRange(frameTimeRange, of: videoTrack, at: reverseTrack?.timeRange.duration ?? .zero)
//            }
//            reverseTrack?.scaleTimeRange(CMTimeRange(start: .zero, duration: reverseTrack!.timeRange.duration), toDuration: scaledDuration)
//            print("Reverse track inserted and scaled.")
//        }
//        
//        return AVVideoComposition(propertiesOf: composition)
//    }
//    
//    private func applyCIFilter(_ filter: CIFilter, to videoComposition: AVVideoComposition, using composition: AVMutableComposition, completion: @escaping (URL?) -> Void) {
//        print("Starting CIFilter application...")
//        
//        let videoCompositionWithFilter = AVVideoComposition(asset: composition) { request in
//            let source = request.sourceImage.clampedToExtent()
//            filter.setValue(source, forKey: kCIInputImageKey)
//            
//            if let output = filter.outputImage {
//                let cropped = output.cropped(to: request.sourceImage.extent)
//                request.finish(with: cropped, context: nil)
//            } else {
//                print("Filter output is nil.")
//                request.finish(with: request.sourceImage, context: nil)
//            }
//        }
//
//        export(composition: composition, videoComposition: videoCompositionWithFilter, completion: completion)
//    }
//    
//    private func export(composition: AVMutableComposition, videoComposition: AVVideoComposition? = nil, completion: @escaping (URL?) -> Void) {
//        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
//        print("Starting export to \(outputURL)...")
//
//        if FileManager.default.fileExists(atPath: outputURL.path) {
//            print("File already exists at \(outputURL). Deleting it.")
//            try? FileManager.default.removeItem(at: outputURL)
//        }
//
//        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
//            print("Failed to create export session.")
//            completion(nil)
//            return
//        }
//        
//        exportSession.outputURL = outputURL
//        exportSession.outputFileType = .mp4
//        exportSession.videoComposition = videoComposition
//        
//        exportSession.exportAsynchronously {
//            switch exportSession.status {
//            case .completed:
//                print("Export completed successfully.")
//                completion(outputURL)
//            case .failed:
//                print("Export failed: \(String(describing: exportSession.error?.localizedDescription))")
//                completion(nil)
//            case .cancelled:
//                print("Export cancelled.")
//                completion(nil)
//            default:
//                print("Export finished with unexpected status: \(exportSession.status.rawValue)")
//                completion(nil)
//            }
//        }
//    }
//}
//
//public enum VideoFilter {
//    case sepia, noir, invert, posterize, vignette, comic, blur, monochrome
//    
//    var filter: CIFilter? {
//        switch self {
//        case .sepia:
//            let filter = CIFilter(name: "CISepiaTone")!
//            filter.setValue(1.0, forKey: kCIInputIntensityKey)
//            return filter
//        case .noir:
//            return CIFilter(name: "CIPhotoEffectNoir")!
//        case .invert:
//            return CIFilter(name: "CIColorInvert")!
//        case .posterize:
//            let filter = CIFilter(name: "CIColorPosterize")!
//            filter.setValue(6.0, forKey: "inputLevels")
//            return filter
//        case .vignette:
//            let filter = CIFilter(name: "CIVignette")!
//            filter.setValue(2.0, forKey: kCIInputIntensityKey)
//            filter.setValue(30.0, forKey: kCIInputRadiusKey)
//            return filter
//        case .comic:
//            return CIFilter(name: "CIComicEffect")!
//        case .blur:
//            let filter = CIFilter(name: "CIGaussianBlur")!
//            filter.setValue(5.0, forKey: kCIInputRadiusKey)
//            return filter
//        case .monochrome:
//            let filter = CIFilter(name: "CIColorMonochrome")!
//            filter.setValue(CIColor(color: .white), forKey: kCIInputColorKey)
//            filter.setValue(1.0, forKey: kCIInputIntensityKey)
//            return filter
//        }
//    }
//}

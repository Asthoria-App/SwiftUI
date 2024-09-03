
import AVFoundation
import CoreImage
import SwiftUI

public class VideoProcessor: ObservableObject {
    private let videoURL: URL
    private let overlayImage: UIImage

    public init(videoURL: URL, overlayImage: UIImage) {
        self.videoURL = videoURL
        self.overlayImage = overlayImage
    }

    public func processVideo(completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: videoURL)
        let composition = AVMutableComposition()

        Task {
            do {
                let videoTrack = try await asset.loadTracks(withMediaType: .video).first
                let originalDuration = try await asset.load(.duration)

                guard let videoTrack = videoTrack else {
                    completion(nil)
                    return
                }

                let videoComposition = try await createOverlayComposition(for: videoTrack, originalDuration: originalDuration, in: composition)

                export(composition: composition, videoComposition: videoComposition, completion: completion)
            } catch {
                completion(nil)
            }
        }
    }
    private func createOverlayComposition(for videoTrack: AVAssetTrack, originalDuration: CMTime, in composition: AVMutableComposition) async throws -> AVMutableVideoComposition {
        let videoComposition = AVMutableVideoComposition()
        let timeRange = CMTimeRange(start: .zero, duration: originalDuration)

        let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        try videoCompositionTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: originalDuration)

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]

        let renderSize = try await videoTrack.load(.naturalSize)
        videoComposition.renderSize = renderSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 10) // 30fps olarak ayarlandı
        
        print("Video Natural Size: \(renderSize)")
        
        let overlayLayer = CALayer()
        overlayLayer.contents = overlayImage.cgImage
        overlayLayer.contentsGravity = .resizeAspect

        overlayLayer.frame = CGRect(origin: .zero, size: renderSize)
        overlayLayer.opacity = 1.0

        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .zero, size: renderSize)

        let parentLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: renderSize)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)

        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)

        return videoComposition
    }



    private func export(composition: AVMutableComposition, videoComposition: AVVideoComposition, completion: @escaping (URL?) -> Void) {
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

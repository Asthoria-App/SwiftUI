
import AVFoundation
import CoreImage
import SwiftUI

public class VideoProcessor: ObservableObject {
    private let videoURL: URL
    private let overlayImage: UIImage
    private let isMuted: Bool
    private let soundURL: URL?

    public init(videoURL: URL, overlayImage: UIImage, isMuted: Bool, soundURL: URL? = nil) {
        self.videoURL = videoURL
        self.overlayImage = overlayImage
        self.isMuted = isMuted
        self.soundURL = soundURL
    }

    public func processVideo(completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: videoURL)
        let composition = AVMutableComposition()

        Task {
            do {
                let videoTrack = try await asset.loadTracks(withMediaType: .video).first
                let originalVideoDuration = try await asset.load(.duration)

                guard let videoTrack = videoTrack else {
                    completion(nil)
                    return
                }

                // Eğer soundURL varsa yeni sesi yükle, yoksa orijinal sesi kullan
                var finalDuration = originalVideoDuration

                if let soundURL = soundURL {
                    let soundAsset = AVAsset(url: soundURL)
                    let soundDuration = try await soundAsset.load(.duration)
                    finalDuration = CMTimeMinimum(originalVideoDuration, soundDuration)

                    let videoComposition = try await createOverlayComposition(for: videoTrack, originalDuration: finalDuration, in: composition)

                    if let soundTrack = try await soundAsset.loadTracks(withMediaType: .audio).first {
                        let soundCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
                        try soundCompositionTrack.insertTimeRange(CMTimeRange(start: .zero, duration: finalDuration), of: soundTrack, at: .zero)
                    }

                    export(composition: composition, videoComposition: videoComposition, completion: completion)
                } else if !isMuted {
                    // Orijinal sesi kullan
                    if let audioTrack = try await asset.loadTracks(withMediaType: .audio).first {
                        let videoComposition = try await createOverlayComposition(for: videoTrack, originalDuration: originalVideoDuration, in: composition)
                        let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
                        try audioCompositionTrack.insertTimeRange(CMTimeRange(start: .zero, duration: originalVideoDuration), of: audioTrack, at: .zero)

                        export(composition: composition, videoComposition: videoComposition, completion: completion)
                    }
                } else {
                    // Sessiz video
                    let videoComposition = try await createOverlayComposition(for: videoTrack, originalDuration: originalVideoDuration, in: composition)
                    export(composition: composition, videoComposition: videoComposition, completion: completion)
                }
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
        videoComposition.frameDuration = CMTime(value: 1, timescale: 10)

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

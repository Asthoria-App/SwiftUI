//
//  VideoProcessor.swift
//
//
//  Created by Aysema Çam on 12.08.2024.
//

import AVFoundation
import SwiftUI

public class VideoProcessor: ObservableObject {
    private let videoURL: URL
    private var speed: Float = 1.0
    private var makeBoomerang: Bool = false
    
    public init(videoURL: URL) {
        self.videoURL = videoURL
    }
    
    public func setSpeed(_ speed: Float) {
        self.speed = speed
    }
    
    public func setVideo(_ speed: Float = 1.0) {
        self.speed = speed
    }
    
    public func setMakeBoomerang(_ makeBoomerang: Bool) {
        self.makeBoomerang = makeBoomerang
    }
    
    public func processVideo(completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: videoURL)
        let composition = AVMutableComposition()
        
        Task {
            do {
                let duration = try await asset.load(.duration)
                
                if #available(iOS 15.0, *) {
                    let tracks = try await asset.loadTracks(withMediaType: .video)
                    guard let videoTrack = tracks.first else {
                        completion(nil)
                        return
                    }
                    
                    try self.processVideoTrack(videoTrack, duration: duration, composition: composition, completion: completion)
                } else {
                    let tracks = asset.tracks(withMediaType: .video)
                    guard let videoTrack = tracks.first else {
                        completion(nil)
                        return
                    }
                    
                    try self.processVideoTrack(videoTrack, duration: duration, composition: composition, completion: completion)
                }
            } catch {
                print("Error loading asset: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    private func processVideoTrack(_ videoTrack: AVAssetTrack, duration: CMTime, composition: AVMutableComposition, completion: @escaping (URL?) -> Void) throws {
        let timeRange = CMTimeRange(start: .zero, duration: duration)
        
        let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        try videoCompositionTrack?.insertTimeRange(timeRange, of: videoTrack, at: .zero)
        videoCompositionTrack?.scaleTimeRange(timeRange, toDuration: CMTimeMultiplyByFloat64(duration, multiplier: 1.0 / Float64(self.speed)))
        
        if self.makeBoomerang {
            let reversedVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            try reversedVideoTrack?.insertTimeRange(timeRange, of: videoTrack, at: duration)
            reversedVideoTrack?.scaleTimeRange(timeRange, toDuration: duration)
        }
        
        self.export(composition: composition, outputFileName: "processed_video.mov", completion: completion)
    }
    
    private func export(composition: AVMutableComposition, outputFileName: String, completion: @escaping (URL?) -> Void) {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")

        if FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                try FileManager.default.removeItem(at: outputURL)
            } catch {
                print("Failed to remove existing file: \(error)")
                completion(nil)
                return
            }
        }

        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(outputURL)
            default:
                print("Export failed: \(exportSession.error?.localizedDescription ?? "unknown error")")
                completion(nil)
            }
        }
    }
}

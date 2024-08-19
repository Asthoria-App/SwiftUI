import AVFoundation
import CoreImage
import SwiftUI

public class VideoProcessor: ObservableObject {
    private let videoURL: URL
    private var speed: Float = 1.0
    private var selectedFilter: VideoFilter = .none

    public init(videoURL: URL) {
        self.videoURL = videoURL
    }

    public func processVideo(speed: Float = 1.0, loopDuration: Double = 0.0, makeLoop: Bool = false, filter: VideoFilter = .none, completion: @escaping (URL?) -> Void) {
        self.speed = speed
        self.selectedFilter = filter
        
        let asset = AVAsset(url: videoURL)
        let composition = AVMutableComposition()

        Task {
            do {
                let videoTrack = try await asset.loadTracks(withMediaType: .video).first
                let originalDuration = try await asset.load(.duration)
                let scaledDuration = CMTimeMultiplyByFloat64(originalDuration, multiplier: 1.0 / Float64(speed))

                guard let videoTrack = videoTrack else {
                    completion(nil)
                    return
                }

                let videoComposition: AVMutableVideoComposition
                if makeLoop {
                    videoComposition = try createLoopingComposition(for: videoTrack, originalDuration: scaledDuration, in: composition, loopDuration: loopDuration)
                } else {
                    videoComposition = try createSimpleComposition(for: videoTrack, originalDuration: scaledDuration, in: composition)
                }

                if let filter = self.selectedFilter.filter {
                    applyCIFilter(filter, to: videoComposition, using: composition, completion: completion)
                } else {
                    export(composition: composition, videoComposition: videoComposition, completion: completion)
                }
            } catch {
                completion(nil)
            }
        }
    }

    private func createLoopingComposition(for videoTrack: AVAssetTrack, originalDuration: CMTime, in composition: AVMutableComposition, loopDuration: Double) throws -> AVMutableVideoComposition {
        let videoComposition = AVMutableVideoComposition()
        let timeRange = CMTimeRange(start: .zero, duration: originalDuration)
        
        let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        try videoCompositionTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)
        
        var currentDuration = originalDuration
        while currentDuration.seconds < loopDuration {
            try videoCompositionTrack.insertTimeRange(timeRange, of: videoTrack, at: currentDuration)
            currentDuration = currentDuration + originalDuration
        }

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: currentDuration)
        instruction.layerInstructions = [AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)]
        videoComposition.instructions = [instruction]

        videoComposition.renderSize = videoTrack.naturalSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        return videoComposition
    }

    private func createSimpleComposition(for videoTrack: AVAssetTrack, originalDuration: CMTime, in composition: AVMutableComposition) throws -> AVMutableVideoComposition {
        let videoComposition = AVMutableVideoComposition()
        let timeRange = CMTimeRange(start: .zero, duration: originalDuration)
        
        let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        try videoCompositionTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: originalDuration)
        instruction.layerInstructions = [AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)]
        videoComposition.instructions = [instruction]

        videoComposition.renderSize = videoTrack.naturalSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        return videoComposition
    }

    private func applyCIFilter(_ filter: CIFilter, to videoComposition: AVMutableVideoComposition, using composition: AVMutableComposition, completion: @escaping (URL?) -> Void) {
        let videoCompositionWithFilter = AVVideoComposition(asset: composition) { request in
            let source = request.sourceImage.clampedToExtent()
            filter.setValue(source, forKey: kCIInputImageKey)
            let output = filter.outputImage?.cropped(to: request.sourceImage.extent)
            request.finish(with: output ?? source, context: nil)
        }

        export(composition: composition, videoComposition: videoCompositionWithFilter, completion: completion)
    }

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
    case none, sepia, noir, invert, posterize, vignette, comic, blur, monochrome
    
    var filter: CIFilter? {
        switch self {
        case .none:
            return nil
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

import AVFoundation
import UIKit

public class VideoCreator {
    public init() {}

    public func createVideo(from images: [UIImage], frameRate: Int, completion: @escaping (URL?) -> Void) {
        guard let firstImage = images.first else {
            print("No images available.")
            completion(nil)
            return
        }

        let videoSize = firstImage.size
        
        let settings = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoSize.width,
            AVVideoHeightKey: videoSize.height
        ] as [String: Any]
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        
        do {
            let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
            let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            let sourcePixelBufferAttributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: videoSize.width,
                kCVPixelBufferHeightKey as String: videoSize.height
            ]
            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
            
            writer.add(writerInput)
            writer.startWriting()
            writer.startSession(atSourceTime: .zero)
            
            var frameCount: Int64 = 0
            let frameDuration = CMTime(value: 1, timescale: CMTimeScale(frameRate))
            
            for image in images {
                guard let pixelBuffer = image.fixedOrientationPixelBuffer(size: videoSize) else { continue }
                
                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                while !writerInput.isReadyForMoreMediaData {
                    Thread.sleep(forTimeInterval: 0.1)
                }
                
                pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                frameCount += 1
            }
            
            writerInput.markAsFinished()
            writer.finishWriting {
                if writer.status == .completed {
                    completion(outputURL)
                } else {
                    completion(nil)
                }
            }
        } catch {
            print("Failed to create video: \(error)")
            completion(nil)
        }
    }
}

extension UIImage {
    func fixedOrientationPixelBuffer(size: CGSize) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
        }
        
        context.clear(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        guard let cgImage = self.cgImage else { return nil }

        let orientedImage = UIImage(cgImage: cgImage, scale: self.scale, orientation: .up)

        let aspectRect = AVMakeRect(aspectRatio: orientedImage.size, insideRect: CGRect(origin: .zero, size: size))
        context.draw(orientedImage.cgImage!, in: aspectRect)
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}


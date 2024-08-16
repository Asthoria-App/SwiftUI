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

public class VideoCreator: ObservableObject {
    
    public init() {}

    public func createBoomerangVideo(from images: [UIImage], completion: @escaping (URL?) -> Void) {
        let forwardImages = images
        let backwardImages = images.reversed()
        let combinedImages = forwardImages + backwardImages

        let size = images.first?.size ?? CGSize(width: 1920, height: 1080)
        let filePath = FileManager.default.temporaryDirectory.appendingPathComponent("boomerang.mov")
        
        guard let videoWriter = try? AVAssetWriter(outputURL: filePath, fileType: .mov) else {
            completion(nil)
            return
        }

        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height
        ]

        let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: nil)

        if videoWriter.canAdd(videoWriterInput) {
            videoWriter.add(videoWriterInput)
        }

        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: .zero)

        var frameCount: Int64 = 0
        let frameDuration = CMTime(value: 1, timescale: 30)

        videoWriterInput.requestMediaDataWhenReady(on: DispatchQueue(label: "videoQueue")) {
            for image in combinedImages {
                if videoWriterInput.isReadyForMoreMediaData {
                    let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                    if let pixelBuffer = self.pixelBufferFromImage(image: image, size: size) {
                        adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                    }
                    frameCount += 1
                }
            }

            videoWriterInput.markAsFinished()
            videoWriter.finishWriting {
                completion(filePath)
            }
        }
    }

    private func pixelBufferFromImage(image: UIImage, size: CGSize) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: kCFBooleanTrue!
        ]

        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options as CFDictionary, &pixelBuffer)

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height),
                                bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        CVPixelBufferUnlockBaseAddress(buffer, [])

        return buffer
    }
}

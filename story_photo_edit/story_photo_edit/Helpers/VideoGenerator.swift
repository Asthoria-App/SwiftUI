//
//  VideoGenerator.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 30.09.2024.
//

import AVFoundation
import UIKit

class VideoGenerator {
    var backgroundImage: UIImage
    var soundURL: URL?
    var selectedEffect: EffectType?

    init(backgroundImage: UIImage, soundURL: URL?, selectedEffect: EffectType? = nil) {
        self.backgroundImage = backgroundImage
        self.soundURL = soundURL
        self.selectedEffect = selectedEffect
    }

    func generateVideo(completion: @escaping (URL?) -> Void) {
        guard let soundURL = soundURL else {
            print("Sound URL is nil")
            completion(nil)
            return
        }

        let audioAsset = AVAsset(url: soundURL)
        let audioDuration = CMTimeGetSeconds(audioAsset.duration)

        let outputSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let fileName = UUID().uuidString + ".mov"
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            let videoWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
            
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: outputSize.width,
                AVVideoHeightKey: outputSize.height
            ]
            
            let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: videoWriterInput,
                sourcePixelBufferAttributes: [
                    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                    kCVPixelBufferWidthKey as String: Float(outputSize.width),
                    kCVPixelBufferHeightKey as String: Float(outputSize.height)
                ]
            )
            
            if videoWriter.canAdd(videoWriterInput) {
                videoWriter.add(videoWriterInput)
            } else {
                completion(nil)
                return
            }
            
            let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
            
            if videoWriter.canAdd(audioInput) {
                videoWriter.add(audioInput)
            } else {
                completion(nil)
                return
            }
            
            videoWriter.startWriting()
            videoWriter.startSession(atSourceTime: .zero)
            
            let frameDuration = CMTime(value: 1, timescale: 24)
            var frameCount: Int64 = 0
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            let videoQueue = DispatchQueue(label: "videoQueue")
            videoWriterInput.requestMediaDataWhenReady(on: videoQueue) {
                while videoWriterInput.isReadyForMoreMediaData {
                    let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                    
                    if presentationTime >= audioAsset.duration {
                        videoWriterInput.markAsFinished()
                        videoWriter.finishWriting {
                            DispatchQueue.main.async {
                                completion(outputURL)
                                dispatchGroup.leave()
                            }
                        }
                        break
                    }
                    
                    guard let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool else {
                        dispatchGroup.leave()
                        return
                    }
                    var pixelBuffer: CVPixelBuffer?
                    CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &pixelBuffer)
                    
                    if let pixelBuffer = pixelBuffer {
                        CVPixelBufferLockBaseAddress(pixelBuffer, [])
                        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
                        let context = CGContext(
                            data: CVPixelBufferGetBaseAddress(pixelBuffer),
                            width: Int(outputSize.width),
                            height: Int(outputSize.height),
                            bitsPerComponent: 8,
                            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                            space: rgbColorSpace,
                            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
                        )
                        
                        context?.draw(self.backgroundImage.cgImage!, in: CGRect(origin: .zero, size: outputSize))
                        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
                        pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                        
                        frameCount += 1
                    }
                }
            }
            
            dispatchGroup.enter()
            DispatchQueue.global().async {
                do {
                    let audioReader = try AVAssetReader(asset: audioAsset)
                    let audioTrack = audioAsset.tracks(withMediaType: .audio).first!
                    print("Audio Track Found: \(audioTrack)")

                    let audioSettings: [String: Any] = [AVFormatIDKey: kAudioFormatLinearPCM]
                    let audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: audioSettings)
                    
                    if audioReader.canAdd(audioOutput) {
                        audioReader.add(audioOutput)
                        print("AudioOutput added")
                    } else {
                        print("Cannot add audioOutput")
                        dispatchGroup.leave()
                        return
                    }

                    if !audioReader.startReading() {
                        print("AudioReader failed to start reading")
                        dispatchGroup.leave()
                        return
                    }

                    let audioQueue = DispatchQueue(label: "audioQueue")
                    audioInput.requestMediaDataWhenReady(on: audioQueue) {
                        while audioInput.isReadyForMoreMediaData {
                            if let sampleBuffer = audioOutput.copyNextSampleBuffer() {
                                print("Sample Buffer received")
                                audioInput.append(sampleBuffer)
                            } else {
                                print("No more sample buffers")
                                audioInput.markAsFinished()
                                audioReader.cancelReading()
                                dispatchGroup.leave()
                                break
                            }
                        }
                    }
                } catch {
                    print("Error processing audio: \(error.localizedDescription)")
                    dispatchGroup.leave()
                }
            }

            
        } catch {
            print("Error generating video with sound: \(error.localizedDescription)")
        }
    }
}

//
//  ContentView.swift
//  test_video_toolbox
//
//  Created by Aysema Çam on 14.01.2025.
//

import SwiftUI
import AVFoundation
import VideoToolbox
import AVKit

struct ContentView: View {
    @State private var isRecording = false
    @State private var videoURL: URL?
    @State private var processedVideoURL: URL?

    var body: some View {
        VStack {
            CameraView(isRecording: $isRecording, videoURL: $videoURL)
                .frame(height: 400)
                .background(Color.black)

            Button(action: startRecording) {
                Text(isRecording ? "Recording..." : "Start Recording")
                    .padding()
                    .background(isRecording ? Color.gray : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isRecording)

            if let videoURL = videoURL {
                Text("Video kaydedildi: \(videoURL.lastPathComponent)")
                    .padding()

                Button(action: {
                    applyVideoEffect(to: videoURL) { newURL in
                        processedVideoURL = newURL
                    }
                }) {
                    Text("Process Video")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            if let processedVideoURL = processedVideoURL {
                Button(action: { playVideo(url: processedVideoURL) }) {
                    Text("Play Processed Video")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }

    func startRecording() {
        isRecording = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            NotificationCenter.default.post(name: .stopRecording, object: nil)
            isRecording = false
        }
    }

    func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player

        UIApplication.shared.windows.first?.rootViewController?.present(playerViewController, animated: true) {
            player.play()
        }
    }

    func applyVideoEffect(to videoURL: URL, completion: @escaping (URL) -> Void) {
        let asset = AVAsset(url: videoURL)
        let composition = AVMutableComposition()

        guard let videoTrack = asset.tracks(withMediaType: .video).first else { return }

        let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        try? videoCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: videoTrack, at: .zero)

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoTrack.naturalSize
        videoComposition.frameDuration = videoTrack.minFrameDuration

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)

        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]

        if let overlayImage = UIImage(named: "aa") {
            CustomVideoCompositor.sharedOverlayImage = CIImage(image: overlayImage)
        }

        videoComposition.customVideoCompositorClass = CustomVideoCompositor.self

        let processedURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")

        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputFileType = .mov
        exporter?.outputURL = processedURL
        exporter?.videoComposition = videoComposition
        exporter?.exportAsynchronously {
            if exporter?.status == .completed {
                DispatchQueue.main.async {
                    completion(processedURL)
                }
            } else if let error = exporter?.error {
                print("Export failed with error: \(error.localizedDescription)")
            }
        }
    }

}

struct CameraView: UIViewControllerRepresentable {
    @Binding var isRecording: Bool
    @Binding var videoURL: URL?

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if isRecording {
            uiViewController.startRecording()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, CameraViewControllerDelegate {
        let parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func didFinishRecording(to outputFileURL: URL) {
            DispatchQueue.main.async {
                self.parent.videoURL = outputFileURL
            }
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didFinishRecording(to outputFileURL: URL)
}

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    var captureSession: AVCaptureSession!
    var movieOutput: AVCaptureMovieFileOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: CameraViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        captureSession = AVCaptureSession()
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }

        captureSession.addInput(videoInput)

        movieOutput = AVCaptureMovieFileOutput()
        captureSession.addOutput(movieOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()

        NotificationCenter.default.addObserver(self, selector: #selector(stopRecording), name: .stopRecording, object: nil)
    }

    func startRecording() {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString + ".mov")
        movieOutput.startRecording(to: tempURL, recordingDelegate: self)
    }

    @objc func stopRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording failed with error: \(error.localizedDescription)")
            return
        }
        delegate?.didFinishRecording(to: outputFileURL)
    }
}
class CustomVideoCompositor: NSObject, AVVideoCompositing {
    static var sharedOverlayImage: CIImage?

    override init() {
        super.init()
    }

    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {}

    func startRequest(_ asyncVideoCompositionRequest: AVAsynchronousVideoCompositionRequest) {
        guard let pixelBuffer = asyncVideoCompositionRequest.sourceFrame(byTrackID: asyncVideoCompositionRequest.sourceTrackIDs[0].int32Value) else {
            asyncVideoCompositionRequest.finish(with: NSError(domain: "CustomCompositor", code: -1, userInfo: nil))
            return
        }

        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        var outputImage = ciImage

        if let overlayImage = CustomVideoCompositor.sharedOverlayImage {
            let overlaySize = ciImage.extent.size
            let overlayPositioned = overlayImage.transformed(by: CGAffineTransform(scaleX: overlaySize.width / overlayImage.extent.size.width,
                                                                                   y: overlaySize.height / overlayImage.extent.size.height))
            outputImage = outputImage.composited(over: overlayPositioned)
        }

        let context = CIContext()
        context.render(outputImage, to: pixelBuffer)

        asyncVideoCompositionRequest.finish(withComposedVideoFrame: pixelBuffer)
    }

    func cancelAllPendingVideoCompositionRequests() {}

    var sourcePixelBufferAttributes: [String: Any]? = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
    ]

    var requiredPixelBufferAttributesForRenderContext: [String: Any] = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
    ]
}


extension Notification.Name {
    static let stopRecording = Notification.Name("stopRecording")
}

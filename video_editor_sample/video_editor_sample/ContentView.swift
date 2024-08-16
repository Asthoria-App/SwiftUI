//import SwiftUI
//import AVKit
//import VideoProcessorSDK // Assuming this is your custom SDK
//
//struct ContentView: View {
//    @StateObject private var videoProcessor = VideoProcessor(videoURL: Bundle.main.url(forResource: "1", withExtension: "mp4")!)
//    @State private var finalVideoURL: URL?
//    @State private var videoSpeed: Float = 1.0
//    @State private var selectedFilter: VideoFilter = .none
//    @State private var makeBoomerang: Bool = false
//    @State private var loopDuration: Double = 10.0
//    @State private var isProcessing: Bool = false
//    
//    var body: some View {
//        VStack {
//            if isProcessing {
//                ProgressView("Processing video...")
//                    .progressViewStyle(CircularProgressViewStyle())
//            } else if let url = finalVideoURL {
//                VideoPlayer(player: AVPlayer(url: url))
//                    .frame(height: 300)
//            } else {
//                Text("Ready to process video")
//            }
//            
//            ScrollView(.horizontal) {
//                HStack {
//                    Button("None") {
//                        selectedFilter = .none
//                        processVideo()
//                    }
//                    Button("Sepia") {
//                        selectedFilter = .sepia
//                        processVideo()
//                    }
//                    Button("Noir") {
//                        selectedFilter = .noir
//                        processVideo()
//                    }
//                    Button("Invert") {
//                        selectedFilter = .invert
//                        processVideo()
//                    }
//                    Button("Posterize") {
//                        selectedFilter = .posterize
//                        processVideo()
//                    }
//                    Button("Vignette") {
//                        selectedFilter = .vignette
//                        processVideo()
//                    }
//                }
//                .padding()
//            }
//            
//            HStack {
//                Button("Speed x1") {
//                    videoSpeed = 1.0
//                    processVideo()
//                }
//                Button("Speed x2") {
//                    videoSpeed = 2.0
//                    processVideo()
//                }
//                Button("Speed x4") {
//                    videoSpeed = 4.0
//                    processVideo()
//                }
//            }
//            .padding()
//
//            HStack {
//                Button("Boomerang On") {
//                    makeBoomerang = true
//                    processVideo()
//                }
//                Button("Boomerang Off") {
//                    makeBoomerang = false
//                    processVideo()
//                }
//            }
//            .padding()
//
//            HStack {
//                Text("Loop Duration: \(Int(loopDuration)) sec")
//                Slider(value: $loopDuration, in: 5...30, step: 1) {
//                    Text("Loop Duration")
//                }
//                .padding()
//                .onChange(of: loopDuration) { _ in
//                    processVideo()
//                }
//            }
//        }
//    }
//    
//    private func processVideo() {
//        isProcessing = true
//        videoProcessor.processVideo(speed: videoSpeed,
//                                    loopDuration: loopDuration,
//                                    makeLoop: makeBoomerang,
//                                    filter: selectedFilter) { url in
//            DispatchQueue.main.async {
//                self.finalVideoURL = url
//                self.isProcessing = false
//            }
//        }
//    }
//}


//import SwiftUI
//import UIKit
//import AVFoundation
//
//struct BoomerangView: View {
//    @StateObject private var boomerangCreator = BoomerangCreator()
//
//    var body: some View {
//        VStack {
//            if let boomerangImages = boomerangCreator.boomerangImages {
//                ImageSlideshowView(images: boomerangImages)
//                    .aspectRatio(contentMode: .fit)
//            } else {
//                Text("Tap the button to create Boomerang")
//                    .padding()
//            }
//
//            Button(action: {
//                boomerangCreator.startAutomaticCapturingBoomerang()
//            }) {
//                Text("Create Boomerang")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//        }
//        .sheet(isPresented: $boomerangCreator.isShowingCamera) {
//            CameraView(images: $boomerangCreator.capturedImages, didFinishCapturing: {
//                boomerangCreator.createBoomerang()
//            }, boomerangCreator: boomerangCreator)
//        }
//        .padding()
//    }
//}
//
//class BoomerangCreator: ObservableObject {
//    @Published var boomerangImages: [Image]? = nil
//    @Published var capturedImages: [UIImage] = []
//    @Published var isShowingCamera = false
//    @Published var imagesCaptured = 0
//    
//    private var timer: Timer?
//    var totalPhotosToCapture = 10
//    
//    func startAutomaticCapturingBoomerang() {
//        capturedImages.removeAll()
//        imagesCaptured = 0
//        isShowingCamera = true
//    }
//
//    func captureImageAutomatically(picker: UIImagePickerController) {
//        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            if self.imagesCaptured < self.totalPhotosToCapture {
//                picker.takePicture()
//            } else {
//                self.timer?.invalidate()
//                picker.dismiss(animated: true) {
//                    self.createBoomerang()
//                }
//            }
//        }
//    }
//
//    func createBoomerang() {
//        let forwardImages = capturedImages
//        let backwardImages = capturedImages.reversed()
//        let combinedImages = forwardImages + backwardImages
//
//        let swiftUIImages = combinedImages.map { Image(uiImage: $0) }
//
//        DispatchQueue.main.async {
//            self.boomerangImages = swiftUIImages
//        }
//    }
//}
//
//struct CameraView: UIViewControllerRepresentable {
//    @Binding var images: [UIImage]
//    var didFinishCapturing: () -> Void
//    @ObservedObject var boomerangCreator: BoomerangCreator
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        picker.sourceType = .camera
//        picker.allowsEditing = false
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//
//    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        let parent: CameraView
//
//        init(_ parent: CameraView) {
//            self.parent = parent
//        }
//
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            picker.dismiss(animated: true)
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let image = info[.originalImage] as? UIImage {
//                parent.images.append(image)
//                parent.boomerangCreator.imagesCaptured += 1
//
//                if parent.boomerangCreator.imagesCaptured < parent.boomerangCreator.totalPhotosToCapture {
//                    parent.boomerangCreator.captureImageAutomatically(picker: picker)
//                } else {
//                    picker.dismiss(animated: true) {
//                        self.parent.didFinishCapturing()
//                    }
//                }
//            }
//        }
//
//        func startAutomaticCapturing(picker: UIImagePickerController) {
//            parent.boomerangCreator.captureImageAutomatically(picker: picker)
//        }
//    }
//}
//struct ImageSlideshowView: View {
//    let images: [Image]
//    @State private var currentIndex = 0
//    @State private var timer: Timer?
//
//    var body: some View {
//        images[currentIndex]
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .transition(.opacity.animation(.easeInOut(duration: 0.1)))
//        
//            .onAppear {
//                startSlideshow()
//            }
//            .onDisappear {
//                stopSlideshow()
//            }
//    }
//
//    private func startSlideshow() {
//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
//            withAnimation {
//                currentIndex = (currentIndex + 1) % images.count
//            }
//        }
//    }
//
//    private func stopSlideshow() {
//        timer?.invalidate()
//    }
//}
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var photos: [UIImage] = []
    @State private var isCapturing = false
    @State private var showBoomerang = false

    var body: some View {
        VStack {
            CameraView(photos: $photos, isCapturing: $isCapturing, showBoomerang: $showBoomerang)
                .frame(height: 400)
                .background(Color.gray.opacity(0.3))
            
            Button(action: {
                if isCapturing {
                    // Stop capturing and show Boomerang
                    isCapturing = false
                    showBoomerang = true
                } else {
                    // Start capturing
                    photos.removeAll()
                    isCapturing = true
                }
            }) {
                Text(isCapturing ? "Stop Capturing" : "Start Capturing")
                    .font(.title)
                    .padding()
                    .background(isCapturing ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Text("Captured Photos: \(photos.count)")
                .padding()
        }
        .fullScreenCover(isPresented: $showBoomerang) {
            let boomerangPhotos = photos + photos.reversed()

            BoomerangView(photos: boomerangPhotos, showBoomerang: $showBoomerang)
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var photos: [UIImage]
    @Binding var isCapturing: Bool
    @Binding var showBoomerang: Bool

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.photos = $photos
        controller.isCapturing = $isCapturing
        controller.showBoomerang = $showBoomerang
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if isCapturing {
            uiViewController.startCaptureTimer()
        } else {
            uiViewController.stopCaptureTimer()
        }
    }
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photos: Binding<[UIImage]>!
    var isCapturing: Binding<Bool>!
    var showBoomerang: Binding<Bool>!

    var captureTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No camera available")
            return
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
            } else {
                print("Couldn't add video device input")
                return
            }
        } catch {
            print("Error setting up camera input: \(error)")
            return
        }
        
        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            print("Couldn't add photo output")
            return
        }
        
        captureSession.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }

    func startCaptureTimer() {
        guard captureTimer == nil else { return }
        captureTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.capturePhoto()
        }
    }

    func stopCaptureTimer() {
        captureTimer?.invalidate()
        captureTimer = nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }

    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let photoData = photo.fileDataRepresentation(), let image = UIImage(data: photoData) else {
            print("Error converting photo data to image")
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.photos.wrappedValue.append(image)
            print("Captured photo, total count: \(self?.photos.wrappedValue.count ?? 0)")
        }
    }
}
import AVFoundation
import UIKit

class BoomerangVideoCreator {
    
    func createBoomerangVideo(from images: [UIImage], frameRate: Int, completion: @escaping (URL?) -> Void) {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("boomerangVideo.mov")
        
        guard let writer = try? AVAssetWriter(outputURL: fileURL, fileType: .mov) else {
            completion(nil)
            return
        }
        
        let videoSize = images.first?.size ?? CGSize(width: 1920, height: 1080)
        let outputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoSize.width,
            AVVideoHeightKey: videoSize.height
        ]
        
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: videoSize.width,
            kCVPixelBufferHeightKey as String: videoSize.height
        ]
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: attributes)
        
        writer.add(writerInput)
        
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        
        var frameCount: Int64 = 0
        let durationPerImage = CMTime(seconds: 1.0 / Double(frameRate), preferredTimescale: 600)
        
        writerInput.requestMediaDataWhenReady(on: DispatchQueue.global(qos: .background)) {
            for image in images {
                while !writerInput.isReadyForMoreMediaData { }
                
                if let buffer = self.pixelBufferFromImage(image: image, size: videoSize) {
                    let time = CMTime(value: frameCount, timescale: 600)
                    adaptor.append(buffer, withPresentationTime: time)
                    frameCount += 1
                }
            }
            
            writerInput.markAsFinished()
            writer.finishWriting {
                completion(writer.status == .completed ? fileURL : nil)
            }
        }
    }
    
    private func pixelBufferFromImage(image: UIImage, size: CGSize) -> CVPixelBuffer? {
        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, attributes as CFDictionary, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
        }
        
        context.clear(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let cgImage = image.cgImage else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}
import AVFoundation
import UIKit

import AVFoundation
import UIKit

class VideoCreator {
    func createVideo(from images: [UIImage], frameRate: Int, completion: @escaping (URL?) -> Void) {
        let videoSize = CGSize(width: 1080, height: 1920)
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
                   
                   // Frame sayısını hesaba katarak sunum süresini ayarlıyoruz
                   let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                   let adjustedPresentationTime = CMTimeMultiplyByRatio(presentationTime, multiplier: 3, divisor: 2)

                   while !writerInput.isReadyForMoreMediaData {
                       Thread.sleep(forTimeInterval: 0.1)
                   }
                   
                   pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: adjustedPresentationTime)
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
        
        // Resmin yönünü sabitle
        guard let cgImage = self.cgImage else { return nil }
        
        let orientedImage = UIImage(cgImage: cgImage, scale: self.scale, orientation: .up)  // Yönü sabitle
        
        let aspectRect = AVMakeRect(aspectRatio: orientedImage.size, insideRect: CGRect(origin: .zero, size: size))
        
        context.draw(orientedImage.cgImage!, in: aspectRect)
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}


import SwiftUI
import AVKit

struct BoomerangView: View {
    var photos: [UIImage]
    @Binding var showBoomerang: Bool
    
    @State private var videoURL: URL?
    
    var body: some View {
        VStack {
            if let videoURL = videoURL {
                // Video URL mevcutsa videoyu göster
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 900)
                    .onAppear {
                        // Videoyu başlat
                        let player = AVPlayer(url: videoURL)
                        player.play()
                    }
            } else {
                Text("Processing Video...")
                    .onAppear {
                        createBoomerangVideo()
                    }
            }
            
            Button("Close") {
                showBoomerang = false
            }
            .font(.title)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    private func createBoomerangVideo() {
        let videoCreator = VideoCreator()
        videoCreator.createVideo(from: photos, frameRate: 30) { videoURL in
            if let url = videoURL {
                print("Video created at: \(url)")
                self.videoURL = url
            } else {
                print("Failed to create video.")
            }
        }

    }
}

//
//  testApp.swift
//  test
//
//  Created by Aysema Çam on 18.09.2024.
//

import SwiftUI

@main
struct testApp: App {
    var body: some Scene {
        WindowGroup {
           ContentView()
        }
    }
}
import SwiftUI
import AVFoundation
import Vision

struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = CameraViewController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var overlayLayer = CAShapeLayer()
    
    private var frameCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Error creating video input: \(error.localizedDescription)")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Unable to add video input.")
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        overlayLayer.frame = view.bounds
        view.layer.addSublayer(overlayLayer)
        
        captureSession.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        frameCounter += 1
        
        if frameCounter % 3 != 0 { return }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let request = VNDetectFaceLandmarksRequest { (req, err) in
                if let error = err {
                    print("Face landmarks error: \(error.localizedDescription)")
                    return
                }
                guard let results = req.results as? [VNFaceObservation] else { return }
                
                DispatchQueue.main.async {
                    self.overlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
                    
                    for result in results {
                        if let landmarks = result.landmarks {
                            self.drawRegion(landmarks.leftEye, in: result, orientation: connection.videoOrientation, color: UIColor.blue.cgColor)
                            self.drawRegion(landmarks.rightEye, in: result, orientation: connection.videoOrientation, color: UIColor.green.cgColor)
                            self.drawRegion(landmarks.nose, in: result, orientation: connection.videoOrientation, color: UIColor.yellow.cgColor)
                            self.drawRegion(landmarks.outerLips, in: result, orientation: connection.videoOrientation, color: UIColor.red.cgColor)
                            self.drawRegion(landmarks.innerLips, in: result, orientation: connection.videoOrientation, color: UIColor.orange.cgColor)
                            self.drawRegion(landmarks.leftEyebrow, in: result, orientation: connection.videoOrientation, color: UIColor.purple.cgColor)
                            self.drawRegion(landmarks.rightEyebrow, in: result, orientation: connection.videoOrientation, color: UIColor.purple.cgColor)
                            self.drawRegion(landmarks.noseCrest, in: result, orientation: connection.videoOrientation, color: UIColor.cyan.cgColor)
                            self.drawRegion(landmarks.medianLine, in: result, orientation: connection.videoOrientation, color: UIColor.magenta.cgColor)
                            self.drawRegion(landmarks.faceContour, in: result, orientation: connection.videoOrientation, color: UIColor.brown.cgColor)
                        }
                    }
                }
            }
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Vision request failed: \(error.localizedDescription)")
            }
        }
    }

    func drawRegion(_ region: VNFaceLandmarkRegion2D?, in observation: VNFaceObservation, orientation: AVCaptureVideoOrientation, color: CGColor) {
        guard let region = region else { return }
        let path = UIBezierPath()
        let points = convertLandmarkPoints(region, in: observation, orientation: orientation)
        
        if let firstPoint = points.first {
            path.move(to: firstPoint)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.close()
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color
        shapeLayer.strokeColor = color
        overlayLayer.addSublayer(shapeLayer)
    }

    private func convertLandmarkPoints(_ landmarkRegion: VNFaceLandmarkRegion2D, in observation: VNFaceObservation, orientation: AVCaptureVideoOrientation) -> [CGPoint] {
        let faceBoundingBox = observation.boundingBox
        let landmarkPoints = landmarkRegion.normalizedPoints
        
        return landmarkPoints.map { point in
            var x = faceBoundingBox.origin.x + point.x * faceBoundingBox.width
            var y = faceBoundingBox.origin.y + point.y * faceBoundingBox.height
            
            if orientation == .portrait || orientation == .portraitUpsideDown {
                x = 1 - x
            }
            
            switch orientation {
            case .landscapeLeft:
                swap(&x, &y)
                y = 1 - y
                x = 1 - x
            case .landscapeRight:
                swap(&x, &y)
            case .portraitUpsideDown:
                x = 1 - x
                y = 1 - y
            default:
                break
            }
            
            let convertedX = x * overlayLayer.bounds.width
            let convertedY = (1 - y) * overlayLayer.bounds.height
            return CGPoint(x: convertedX, y: convertedY)
        }
    }
}


//struct ContentView: View {
//    var body: some View {
//        CameraView()
//            .edgesIgnoringSafeArea(.all)
//    }
//}

import SwiftUI
import AVFoundation
import Vision
//import CoreImage
//import CoreImage.CIFilterBuiltins


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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
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
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectFaceLandmarksRequest { (req, err) in
            if let error = err {
                print("Face landmarks error: \(error.localizedDescription)")
                return
            }
            guard let results = req.results as? [VNFaceObservation] else { return }
            
            DispatchQueue.main.async {
                self.overlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
                
                for result in results {
                    if let landmarks = result.landmarks, let outerLips = landmarks.outerLips, let innerLips = landmarks.innerLips {
                        self.drawLips(outerLips, in: result, orientation: connection.videoOrientation, color: UIColor.red.withAlphaComponent(0.5).cgColor)
                        self.drawLips(innerLips, in: result, orientation: connection.videoOrientation, color: UIColor.red.withAlphaComponent(0.5
                                                                                                                                            ).cgColor)
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
    
    func drawLips(_ lips: VNFaceLandmarkRegion2D, in faceObservation: VNFaceObservation, orientation: AVCaptureVideoOrientation, color: CGColor) {
        let path = UIBezierPath()
        let faceBoundingBox = faceObservation.boundingBox
        
        // Dudak noktalarını overlay layer'a uygun şekilde dönüştür
        let points = lips.normalizedPoints.map { point -> CGPoint in
            var x = faceBoundingBox.origin.x + point.x * faceBoundingBox.width
            var y = faceBoundingBox.origin.y + point.y * faceBoundingBox.height
            
            // Cihazın oryantasyonuna göre koordinatları düzenleyin
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
        
        // Catmull-Rom splines kullanarak pürüzsüz çizim
        if points.count > 2 {
            path.move(to: points.first!)
            for i in 1..<points.count - 1 {
                let p0 = points[i - 1]
                let p1 = points[i]
                let p2 = points[i + 1]
                let midPoint = midPointForPoints(p1: p1, p2: p2)
                
                // İki nokta arasında pürüzsüz bir eğri çizin
                path.addQuadCurve(to: midPoint, controlPoint: p1)
            }
            path.addLine(to: points.last!)
            path.close()
        }
        
        // Çizimi layer'a ekle
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color
        shapeLayer.strokeColor = color
        overlayLayer.addSublayer(shapeLayer)
    }

    // İki nokta arasında orta noktayı hesaplar
    func midPointForPoints(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }

}

struct ContentView: View {
    var body: some View {
        CameraView()
            .edgesIgnoringSafeArea(.all)
    }
  }

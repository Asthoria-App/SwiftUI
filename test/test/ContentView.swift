import SwiftUI
import AVFoundation
import Vision

struct CameraView: UIViewRepresentable {
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        var sequenceRequestHandler = VNSequenceRequestHandler()

        init(parent: CameraView) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            let detectFaceRequest = VNDetectFaceLandmarksRequest { request, error in
                if let results = request.results as? [VNFaceObservation], let face = results.first {
                    DispatchQueue.main.async {
                        self.parent.handleFaceLandmarks(face)
                    }
                }
            }
            
            do {
                try sequenceRequestHandler.perform([detectFaceRequest], on: pixelBuffer)
            } catch {
                print("Yüz tespiti sırasında hata: \(error)")
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        
        // Ön kamerayı seçiyoruz
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return view
        }
        
        session.addInput(input)
        
        // Video verilerini işlemek için bir çıktı oluşturuyoruz
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
        session.addOutput(videoOutput)
        
        // Canlı önizleme katmanını ekliyoruz
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    // Dudakları tespit edip ruj uygulama
    func handleFaceLandmarks(_ face: VNFaceObservation) {
        guard let landmarks = face.landmarks, let lips = landmarks.outerLips else { return }
        
        let path = UIBezierPath()
        for i in 0..<lips.pointCount {
            let point = lips.normalizedPoints[i]
            let scaledPoint = CGPoint(x: point.x * UIScreen.main.bounds.width, y: (1 - point.y) * UIScreen.main.bounds.height)
            if i == 0 {
                path.move(to: scaledPoint)
            } else {
                path.addLine(to: scaledPoint)
            }
        }
        path.close()
        
        // Dudaklara kırmızı ruj uyguluyoruz
        let lipsLayer = CAShapeLayer()
        lipsLayer.path = path.cgPath
        lipsLayer.fillColor = UIColor.red.withAlphaComponent(0.8).cgColor
        
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                window.layer.sublayers?.removeAll(where: { $0 is CAShapeLayer }) // Önceki katmanları kaldırıyoruz
                window.layer.addSublayer(lipsLayer) // Yeni kırmızı katmanı ekliyoruz
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        CameraView()
            .edgesIgnoringSafeArea(.all) // Kamera görünümü tam ekran yapıyoruz
    }
}

@main
struct CameraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

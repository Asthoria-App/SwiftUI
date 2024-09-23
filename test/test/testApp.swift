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



//import SwiftUI
//import ARKit
//import SceneKit
//
//struct ARFaceFilterView: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> ARFaceFilterViewController {
//        return ARFaceFilterViewController()
//    }
//    
//    func updateUIViewController(_ uiViewController: ARFaceFilterViewController, context: Context) {}
//}
//
//struct ContentView: View {
//    var body: some View {
//        ARFaceFilterView()
//            .edgesIgnoringSafeArea(.all)
//    }
//}
//
//class ARFaceFilterViewController: UIViewController, ARSCNViewDelegate {
//    var sceneView: ARSCNView!
//    var lowerLipNode: SCNNode?
//    
//    let lowerLipIndices: [[Int32]] = [
//        // MARK: - top lips, right, first layer
//      
//        [22, 671, 541],
//        [671, 543, 541],
//        [543, 671, 672],
//        [545, 672, 673],
//        [543, 672, 545],
//        [557, 545, 673],
//        [556, 557, 674],
//        [674, 557, 673],
//        [675, 556, 674],
//        [553, 556, 675],
//        [676, 553, 675],
//        [676, 635, 553],
//        [677, 635, 676],
//        [677, 635, 826],
//        [677, 825, 636],
//        [677, 826, 635],
//        [825, 826, 677],
//        
//        // MARK: - top lips, right, second layer
//        
//        [],
//        [],
//        [],
//        [],
//        [],
//        [],
//        [],
//        [],
//        [],
//        [],
//        [],
//        [],
//        [],
//        [],
//        [],
//        [],
//        
//        
//        
//        
//     
//        
//        
//        
//        
//        
//        
//
//        // MARK: - top lips, left, first layer
//        [92, 237, 22],
//        [237, 92, 94],
//        [238, 237, 94],
//        [238, 94, 96],
//        [239, 238, 96],
//        [239, 96, 108],
//        [239, 108, 240],
//        [240, 108, 107],
//        [240, 107, 241],
//        [241, 107, 104],
//        [241, 104, 242],
//        [242, 104, 186],
//        [242, 186, 243],
//        [243, 186, 396],
//        [243, 396, 395],
//        [190, 395, 396],
//        
//        // MARK: - top lips, left, first layer
//        
//        
//
//    ]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        sceneView = ARSCNView(frame: self.view.bounds)
//        sceneView.delegate = self
//        sceneView.automaticallyUpdatesLighting = true
//        sceneView.debugOptions = [.showWireframe, .showBoundingBoxes, .showCreases, .showConstraints]
//        view.addSubview(sceneView)
//        
//        let configuration = ARFaceTrackingConfiguration()
//        sceneView.session.run(configuration)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        sceneView.session.pause()
//    }
//    
//    // Renderer başlangıcında yüz ve alt dudağı oluşturuluyor
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
//        
//        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
//        let faceGeometry = ARSCNFaceGeometry(device: device)
//        let node = SCNNode(geometry: faceGeometry)
//        node.geometry?.firstMaterial?.fillMode = .lines
//        
//        addLowerLipSurface(to: node, from: faceAnchor)
//        
//        return node
//    }
//    
//    // Alt dudağın yüzeyini ekleme
//    func addLowerLipSurface(to node: SCNNode, from faceAnchor: ARFaceAnchor) {
//        let vertices = faceAnchor.geometry.vertices.map { SCNVector3($0.x, $0.y, $0.z) }
//        
//        // SCNGeometrySource oluşturma
//        let vertexSource = SCNGeometrySource(vertices: vertices)
//        
//        // Manuel olarak belirlenen üçgenler için index oluşturma
//        var indices: [Int32] = []
//        for triangle in lowerLipIndices {
//            indices += triangle
//        }
//        
//        // Geometrik element oluşturma
//        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
//        let geometryElement = SCNGeometryElement(data: indexData,
//                                                 primitiveType: .triangles,
//                                                 primitiveCount: indices.count / 3,
//                                                 bytesPerIndex: MemoryLayout<Int32>.size)
//        
//        // Geometriyi oluşturuyoruz ve malzemeyi ayarlıyoruz
//        let geometry = SCNGeometry(sources: [vertexSource], elements: [geometryElement])
//        
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red.withAlphaComponent(0.9) // Yarı saydam kırmızı
//        material.isDoubleSided = true
//        geometry.materials = [material]
//
//        // Geometriyi node'a ekliyoruz
//        let lipNode = SCNNode(geometry: geometry)
//        lipNode.renderingOrder = 200
//        node.addChildNode(lipNode)
//        lowerLipNode = lipNode
//    }
//
//    // Renderer güncelleme sırasında alt dudağı güncelleme
//    func renderer(
//        _ renderer: SCNSceneRenderer,
//        didUpdate node: SCNNode,
//        for anchor: ARAnchor) {
//            
//            guard let faceAnchor = anchor as? ARFaceAnchor,
//                  let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
//                return
//            }
//            faceGeometry.update(from: faceAnchor.geometry)
//            updateLowerLipSurface(from: faceAnchor)
//        }
//    
//    // Alt dudağı güncelleme
//    func updateLowerLipSurface(from faceAnchor: ARFaceAnchor) {
//        guard let lowerLipNode = lowerLipNode else { return }
//        
//        let vertices = faceAnchor.geometry.vertices.map { SCNVector3($0.x, $0.y, $0.z) }
//        
//        // SCNGeometrySource oluşturma
//        let vertexSource = SCNGeometrySource(vertices: vertices)
//        
//        // Mevcut üçgenler için index oluşturma
//        var indices: [Int32] = []
//        for triangle in lowerLipIndices {
//            indices += triangle
//        }
//        
//        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
//        let geometryElement = SCNGeometryElement(data: indexData,
//                                                 primitiveType: .triangles,
//                                                 primitiveCount: indices.count / 3,
//                                                 bytesPerIndex: MemoryLayout<Int32>.size)
//        
//        // SCNGeometry oluşturma
//        let geometry = SCNGeometry(sources: [vertexSource], elements: [geometryElement])
//        
//        // Malzeme ayarlama
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red.withAlphaComponent(0.9) // Yarı saydam kırmızı
//        geometry.materials = [material]
//        
//        // Mevcut geometry'i güncellemek yerine yeni geometry atama
//        lowerLipNode.geometry = geometry
//    }
//}

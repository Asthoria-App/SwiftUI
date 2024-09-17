import SwiftUI
import ARKit
import SceneKit

@main
struct story_photo_editApp: App {
    var body: some Scene {
        WindowGroup {
            ARFaceFilterView()
        }
    }
}

struct ARFaceFilterView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARFaceFilterViewController {
        return ARFaceFilterViewController()
    }
    
    func updateUIViewController(_ uiViewController: ARFaceFilterViewController, context: Context) {}
}

class ARFaceFilterViewController: UIViewController, ARSCNViewDelegate {
    var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = ARSCNView(frame: self.view.frame)
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
        
        view.addSubview(sceneView)
    }
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
          guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
          
          let faceNode = SCNNode()
          
          let glassesNode = createGlassesMaskNode()
          faceNode.addChildNode(glassesNode)
          
          let occlusionNode = createOcclusionNode(for: faceAnchor)
          faceNode.addChildNode(occlusionNode)
          
          return faceNode
      }
      
    
    private func createHalfMaskNode() -> SCNNode {
        guard let maskScene = try? SCNScene(named: "Half_Mask.usdz") else {
            print("Mask model not found")
            return SCNNode()
        }
        
        let maskNode = maskScene.rootNode.clone()
        
        maskNode.scale = SCNVector3(0.0095, 0.0095, 0.0095)
        
        maskNode.position = SCNVector3(0, 0.0, 0.1)
        
        return maskNode
    }
    
    private func createBeardMaskNode() -> SCNNode {
        guard let maskScene = try? SCNScene(named: "Beard.usdz") else {
            print("Mask model not found")
            return SCNNode()
        }
        
        let maskNode = maskScene.rootNode.clone()
        
        maskNode.scale = SCNVector3(0.0089, 0.0089, 0.0089)
        
        maskNode.position = SCNVector3(-0.004, -0.08, 0.05)

        return maskNode
    }
    
    
    // Gözlük node'u
    private func createGlassesMaskNode() -> SCNNode {
        guard let maskScene = try? SCNScene(named: "Glasses.usdz") else {
            print("Mask model not found")
            return SCNNode()
        }
        
        let maskNode = maskScene.rootNode.clone()
        maskNode.scale = SCNVector3(0.0009, 0.0009, 0.0009)
        maskNode.position = SCNVector3(0.0, 0.02, 0.05)
        
        return maskNode
    }


    
    private func createVeniceMaskNode() -> SCNNode {
        guard let maskScene = try? SCNScene(named: "Venice_Mask.usdz") else {
            print("Mask model not found")
            return SCNNode()
        }
        
        let maskNode = maskScene.rootNode.clone()
        
        maskNode.scale = SCNVector3(0.08, 0.08, 0.08)
        
        maskNode.position = SCNVector3(0, -0.224, 0.02)
        
        return maskNode
    }
    
       private func createOcclusionNode(for faceAnchor: ARFaceAnchor) -> SCNNode {
           let occlusionGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
           occlusionGeometry.firstMaterial?.colorBufferWriteMask = []
           occlusionGeometry.firstMaterial?.isDoubleSided = true
           
           let occlusionNode = SCNNode(geometry: occlusionGeometry)
           occlusionNode.renderingOrder = -1
           
           return occlusionNode
       }

       func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
           guard let faceAnchor = anchor as? ARFaceAnchor,
                 let occlusionNode = node.childNodes.first(where: { $0.geometry is ARSCNFaceGeometry }) else {
               return
           }
           
           // Yüz takibi güncelleniyor
           let faceGeometry = occlusionNode.geometry as? ARSCNFaceGeometry
           faceGeometry?.update(from: faceAnchor.geometry)
       }

}
//import SwiftUI
//import ARKit
//import SceneKit
//import Vision
//
//class ARFaceFilterViewController: UIViewController, ARSCNViewDelegate {
//    var sceneView: ARSCNView!
//    var faceLandmarksRequest = VNDetectFaceLandmarksRequest()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        sceneView = ARSCNView(frame: self.view.frame)
//        sceneView.delegate = self
//        sceneView.automaticallyUpdatesLighting = true
//        
//        let configuration = ARFaceTrackingConfiguration()
//        sceneView.session.run(configuration)
//        
//        view.addSubview(sceneView)
//    }
//    
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
//        
//        let faceNode = SCNNode()
//        
//        // Yüzde dudakları kırmızı yapma işlemi
//        let lipNode = createLipNode(for: faceAnchor)
//        faceNode.addChildNode(lipNode)
//        
//        return faceNode
//    }
//    
//    // Dudakları kırmızı yapacak node oluşturma
//    private func createLipNode(for faceAnchor: ARFaceAnchor) -> SCNNode {
//        let lipNode = SCNNode()
//        
//        // Dudak bölgesi için basit kırmızı bir geometri
//        let lipsGeometry = SCNPlane(width: 0.02, height: 0.01)
//        lipsGeometry.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.7)
//        
//        let leftLipNode = SCNNode(geometry: lipsGeometry)
//        let rightLipNode = SCNNode(geometry: lipsGeometry)
//        
//        // Dudakların konumlandırılması
//        leftLipNode.position = SCNVector3(faceAnchor.leftEyePose.translation.x, faceAnchor.leftEyePose.translation.y, faceAnchor.leftEyePose.translation.z)
//        rightLipNode.position = SCNVector3(faceAnchor.rightEyePose.translation.x, faceAnchor.rightEyePose.translation.y, faceAnchor.rightEyePose.translation.z)
//        
//        lipNode.addChildNode(leftLipNode)
//        lipNode.addChildNode(rightLipNode)
//        
//        return lipNode
//    }
//    
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
//        
//        let transform = SCNMatrix4(faceAnchor.transform)
//        node.transform = transform
//    }
//}

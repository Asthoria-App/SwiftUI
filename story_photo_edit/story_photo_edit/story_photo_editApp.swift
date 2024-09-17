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
        
        let maskNode = createBeardMaskNode()
        faceNode.addChildNode(maskNode)
        
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
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        let transform = SCNMatrix4(faceAnchor.transform)
        node.transform = transform
    }
}

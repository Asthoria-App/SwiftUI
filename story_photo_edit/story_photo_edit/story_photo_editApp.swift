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
        
        let glassesNode = createGlassesNode()
        faceNode.addChildNode(glassesNode)
        
        return faceNode
    }
    
    private func createGlassesNode() -> SCNNode {
        let glassesNode = SCNNode()
        
        let glassesImage = UIImage(named: "effect1")!
        let glassesPlane = SCNPlane(width: 0.15, height: 0.15)
        
        let glassesMaterial = SCNMaterial()
        glassesMaterial.diffuse.contents = glassesImage
        glassesPlane.materials = [glassesMaterial]
        
        let glassesImageNode = SCNNode(geometry: glassesPlane)
        glassesImageNode.position = SCNVector3(0, 0.02, 0.08)
        

        glassesNode.addChildNode(glassesImageNode)
        
        return glassesNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        let transform = SCNMatrix4(faceAnchor.transform)
        node.transform = transform
    }
}

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
        
        // Configure face tracking
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
        view.addSubview(sceneView)
    }
    
    // Add glasses when the face is detected
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
        
        let faceNode = SCNNode()
        
        // Add 2D glasses image to the face
        let glassesNode = createGlassesNode()
        faceNode.addChildNode(glassesNode)
        
        return faceNode
    }
    
    // Function to create a glasses node using a 2D image
    private func createGlassesNode() -> SCNNode {
        let glassesNode = SCNNode()
        
        // Load the glasses image from assets
        let glassesImage = UIImage(named: "aaa")!
        let glassesPlane = SCNPlane(width: 0.15, height: 0.05) // Adjust the size to fit the face
        
        let glassesMaterial = SCNMaterial()
        glassesMaterial.diffuse.contents = glassesImage
        glassesPlane.materials = [glassesMaterial]
        
        let glassesImageNode = SCNNode(geometry: glassesPlane)
        glassesImageNode.position = SCNVector3(0, 0.02, 0.08) // Position it in front of the face
        
        // Attach glasses node
        glassesNode.addChildNode(glassesImageNode)
        
        return glassesNode
    }
    
    // Update the position and orientation of the glasses node based on the face anchor
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        let transform = SCNMatrix4(faceAnchor.transform)
        node.transform = transform
    }
}

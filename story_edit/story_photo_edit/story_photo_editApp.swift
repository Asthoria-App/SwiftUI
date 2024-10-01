import SwiftUI
import ARKit
import SceneKit

@main
struct story_photo_editApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var selectedBackgroundType: BackgroundType = .photo
    @State private var backgroundImage: UIImage? = UIImage(named: "image")
    @State private var inputVideoURL: URL? = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")
    @State private var showStoryEditView: Bool = false
    

    var body: some View {
        VStack(spacing: 20) {
            Button("Video") {
                selectedBackgroundType = .video
                showStoryEditView = true
            }
          
            
            Button("Photo") {
                selectedBackgroundType = .photo
                showStoryEditView = true
            }
        }
        
        .fullScreenCover(isPresented: $showStoryEditView) {
                 StoryEditView(
                     backgroundType: $selectedBackgroundType,
                     backgroundImage: $backgroundImage,
                     inputVideoURL: $inputVideoURL
                 )
             }
    }
}


// for test mask

struct ARFaceFilterView: UIViewControllerRepresentable {
    @Binding var selectedMask: MaskType

    func makeUIViewController(context: Context) -> ARFaceFilterViewController {
        let viewController = ARFaceFilterViewController()
        viewController.selectedMask = selectedMask
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ARFaceFilterViewController, context: Context) {
        uiViewController.updateMask(selectedMask: selectedMask)
    }
}

enum MaskType {
    case glasses, halfMask, beard, hair1, hair2
}

struct MaskView: View {
    @State private var selectedMask: MaskType = .glasses

    var body: some View {
        VStack {
            ARFaceFilterView(selectedMask: $selectedMask)
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                Button("Glasses") {
                    selectedMask = .glasses
                }
                Button("Half Mask") {
                    selectedMask = .halfMask
                }
                Button("Beard") {
                    selectedMask = .beard
                }
                
                Button("Hair1") {
                    selectedMask = .hair1
                }
            }
            .padding()
        }
    }
}

class ARFaceFilterViewController: UIViewController, ARSCNViewDelegate {
    var sceneView: ARSCNView!
    var selectedMask: MaskType = .glasses
    private var currentMaskNode: SCNNode?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad - ARFaceFilterViewController initialized")
        
        sceneView = ARSCNView(frame: self.view.frame)
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
        print("AR session started with face tracking configuration")
        
        view.addSubview(sceneView)
    }

    func updateMask(selectedMask: MaskType) {
        print("Updating mask to: \(selectedMask)")
        self.selectedMask = selectedMask
        
        if let currentNode = currentMaskNode {
            print("Removing current mask node")
            currentNode.removeFromParentNode()
        }
        
        guard let faceNode = sceneView.scene.rootNode.childNodes.first(where: { $0.name == "faceNode" }),
              let faceAnchor = sceneView.session.currentFrame?.anchors.compactMap({ $0 as? ARFaceAnchor }).first else {
            print("Error: Face node or face anchor not found, trying to reinitialize")
            return
        }
        
        print("Face node found, updating mask node")
        updateMaskNode(on: faceNode, for: faceAnchor)
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            print("Error: Anchor is not ARFaceAnchor")
            return nil
        }
        
        print("ARFaceAnchor detected")
        let faceNode = SCNNode()
        faceNode.name = "faceNode"
        
        let occlusionNode = createOcclusionNode(for: faceAnchor)
        faceNode.addChildNode(occlusionNode)
        print("Occlusion node added")
        
        updateMaskNode(on: faceNode, for: faceAnchor)
        
        return faceNode
    }


    private func updateMaskNode(on faceNode: SCNNode, for faceAnchor: ARFaceAnchor) {
        print("Updating mask node on faceNode")
        
        switch selectedMask {
        case .glasses:
            print("Creating glasses mask node")
            currentMaskNode = createGlassesMaskNode()
        case .halfMask:
            print("Creating half mask node")
            currentMaskNode = createHalfMaskNode()
        case .hair1:
            print("Creating hair1 mask node")
            currentMaskNode = createHair1MaskNode(for: faceAnchor)
        case .hair2:
            print("Creating hair2 mask node")
            currentMaskNode = createHair2MaskNode()
        case .beard:
            print("Creating beard mask node")
            currentMaskNode = createBeardMaskNode()
        }

        if let maskNode = currentMaskNode {
            print("Adding new mask node to faceNode", maskNode)
            faceNode.addChildNode(maskNode)
        } else {
            print("Error: Mask node is nil")
        }
    }


    private func createHalfMaskNode() -> SCNNode {
        guard let maskScene = try? SCNScene(named: "Half_Mask.usdz") else {
            print("Error: Half Mask model not found")
            return SCNNode()
        }
        let maskNode = maskScene.rootNode.clone()
        maskNode.scale = SCNVector3(0.0095, 0.0095, 0.0095)
        maskNode.position = SCNVector3(0, 0.0, 0.05)
        print("Half mask node created")
        return maskNode
    }
    private func createHair1MaskNode(for faceAnchor: ARFaceAnchor) -> SCNNode {
        guard let maskScene = try? SCNScene(named: "Hair_2.usdz") else {
            print("Error: Hair model not found")
            return SCNNode()
        }
        
        let maskNode = maskScene.rootNode.clone()
        
        maskNode.scale = SCNVector3(0.2, 0.2, 0.2)
        
        let faceTransform = faceAnchor.transform
        let facePosition = SCNVector3(faceTransform.columns.3.x, faceTransform.columns.3.y, faceTransform.columns.3.z)
        
        maskNode.position = SCNVector3(facePosition.x, facePosition.y + 0.15, facePosition.z - 0.05)
        
        maskNode.transform = SCNMatrix4(faceTransform)

        print("Hair model created and positioned correctly on head")
        return maskNode
    }


    private func createHair2MaskNode() -> SCNNode {
        guard let maskScene = try? SCNScene(named: "Hair_2.usdz") else {
            print("Error: Hair2 model not found")
            return SCNNode()
        }
        let maskNode = maskScene.rootNode.clone()
        maskNode.scale = SCNVector3(0.00095, 0.00095, 0.00095)
        maskNode.position = SCNVector3(0, 0.0, 0.05)
        print("Hair2 mask node created")
        return maskNode
    }


    private func createBeardMaskNode() -> SCNNode {
        guard let maskScene = try? SCNScene(named: "Beard.usdz") else {
            print("Error: Beard model not found")
            return SCNNode()
        }
        let maskNode = maskScene.rootNode.clone()
        maskNode.scale = SCNVector3(0.0089, 0.0089, 0.0089)
        maskNode.position = SCNVector3(-0.004, -0.08, 0.05)
        print("Beard mask node created")
        return maskNode
    }

    private func createGlassesMaskNode() -> SCNNode {
        guard let maskScene = try? SCNScene(named: "Glasses.usdz") else {
            print("Error: Glasses model not found")
            return SCNNode()
        }
        let maskNode = maskScene.rootNode.clone()
        maskNode.scale = SCNVector3(0.0009, 0.0009, 0.0009)
        maskNode.position = SCNVector3(0.0, 0.02, 0.05)
        print("Glasses mask node created")
        return maskNode
    }
    private func createOcclusionNode(for faceAnchor: ARFaceAnchor) -> SCNNode {
         let occlusionGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
         occlusionGeometry.firstMaterial?.colorBufferWriteMask = []
         occlusionGeometry.firstMaterial?.isDoubleSided = true
         
         let occlusionNode = SCNNode(geometry: occlusionGeometry)
         occlusionNode.renderingOrder = -1
         
         print("Occlusion node created")
         return occlusionNode
     }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            print("Error: Anchor is not ARFaceAnchor")
            return
        }
        
        guard let occlusionNode = node.childNodes.first(where: { $0.geometry is ARSCNFaceGeometry }) else {
            return
        }
        
        let faceGeometry = occlusionNode.geometry as? ARSCNFaceGeometry
        faceGeometry?.update(from: faceAnchor.geometry)
        
    }

}

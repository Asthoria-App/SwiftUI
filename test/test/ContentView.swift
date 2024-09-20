import SwiftUI
import ARKit
import SceneKit

struct ARFaceFilterView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARFaceFilterViewController {
        return ARFaceFilterViewController()
    }
    
    func updateUIViewController(_ uiViewController: ARFaceFilterViewController, context: Context) {}
}

struct ContentView: View {
    var body: some View {
        ARFaceFilterView()
            .edgesIgnoringSafeArea(.all)
    }
}

class ARFaceFilterViewController: UIViewController, ARSCNViewDelegate {
    var sceneView: ARSCNView!
    var redSphereNodes: [SCNNode] = []
    var numberLabels: [SCNNode] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = ARSCNView(frame: self.view.bounds)
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.debugOptions = [.showFeaturePoints]
        view.addSubview(sceneView)
        
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }

        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.fillMode = .lines

        addRedPoints(to: node, from: faceAnchor)

        return node
    }

    func addRedPoints(to node: SCNNode, from faceAnchor: ARFaceAnchor) {
        let points: [Int] = Array(1...1000)


        for (index, pointIndex) in points.enumerated() {
            let vertex = faceAnchor.geometry.vertices[pointIndex]
            let redSphereNode = createRedSphere(at: vertex)
            node.addChildNode(redSphereNode)
            redSphereNodes.append(redSphereNode)
            
            let numberLabel = createNumberLabel(for: pointIndex)
            redSphereNode.addChildNode(numberLabel)
            numberLabels.append(numberLabel)
        }
    }

    func createRedSphere(at position: simd_float3) -> SCNNode {
        let sphereGeometry = SCNSphere(radius: 0.0003)
        sphereGeometry.firstMaterial?.diffuse.contents = UIColor.red

        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.position = SCNVector3(position.x, position.y, position.z)
        return sphereNode
    }

    func createNumberLabel(for index: Int) -> SCNNode {
        let text = SCNText(string: "\(index)", extrusionDepth: 1.0)
        text.font = UIFont.systemFont(ofSize: 10)
        text.flatness = 0.1
        text.firstMaterial?.diffuse.contents = UIColor.yellow
        
        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(0.0002, 0.0002, 0.0002)
        
        textNode.position = SCNVector3(0, 0.0001, 0)
        
        textNode.constraints = [SCNBillboardConstraint()]
        
        return textNode
    }

    func updateRedPoints(from faceAnchor: ARFaceAnchor) {
        let points: [Int] = Array(1...1000)

        for (index, sphereNode) in redSphereNodes.enumerated() {
            let pointIndex = points[index]
            let vertex = faceAnchor.geometry.vertices[pointIndex]
            sphereNode.position = SCNVector3(vertex.x, vertex.y, vertex.z)
            
        }
    }
    
    func updateNumberLabels(from faceAnchor: ARFaceAnchor) {
        let points: [Int] = Array(1...1000)

        for (index, labelNode) in numberLabels.enumerated() {
            let pointIndex = points[index]
            let vertex = faceAnchor.geometry.vertices[pointIndex]
            labelNode.parent?.position = SCNVector3(vertex.x, vertex.y, vertex.z)
        }
    }

    func renderer(
        _ renderer: SCNSceneRenderer,
        didUpdate node: SCNNode,
        for anchor: ARAnchor) {
        
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
            return
        }
        faceGeometry.update(from: faceAnchor.geometry)
        updateRedPoints(from: faceAnchor)
        updateNumberLabels(from: faceAnchor)
    }
}



//        let points: [Int] = [
//            250, 251, 252, 253, 254, 255, 256, // Ağız Üst Sol
//            24, // Ağız Üst Merkez
//            691, 690, 689, 688, 687, 686, 685, // Ağız Üst Sağ
//            684, // Ağız Sağ
//            682, 683, 700, 709, 710, 725, // Ağız Alt Sağ
//            25, // Ağız Alt Merkez
//            265, 274, 290, 275, 247, 248, // Ağız Alt Sol
//            249, // Ağız Sol
//            1090, 1091, 1092, 1093, 1094, 1095, 1096, 1097, 1098, 1099, 1100, 1101, // Sol Göz Üst
//            1102, 1103, 1104, 1105, 1106, 1107, 1108, // Sol Göz Alt
//            1069, 1070, 1071, 1072, 1073, 1074, 1075, 1076, 1077, 1078, 1079, 1080, // Sağ Göz Üst
//            1081, 1082, 1083, 1084, 1085, 1086, 1087, 1088, 1089, 1090, 1091, 1092, // Sağ Göz Alt
//            25, 249, 99, 98, 91, 90, 22, 24, 248, 98, 90, 21, 23 // Ekstra Noktalar
//        ] bu array belirtilen sayıları değil de 1 den 1000 e kadar olan sayıları içersin

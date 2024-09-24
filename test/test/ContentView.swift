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
    var lowerLipNode: SCNNode?
    var eyeLashNode: SCNNode?
    var eyelinerNode: SCNNode?
    
    let eyelinerVerticesIndices: [[Int32]] = [
        
        [1090, 1191, 1091],
        
        [1091, 1191, 1092],
        [1092, 1191, 1190],
        
        [1092, 1190, 1093],
        [1093, 1190, 1189],
        
        [1094, 1093, 1189],
        [1189, 1188, 1094],
        
        [1095, 1094, 1187],
        [1187, 1094, 1188],
        
        [1096, 1095, 1187],
        [1096, 1187, 1186],
        
        [1097, 1096, 1185],
        [1185, 1096, 1186],
        
        [1098, 1097, 1185],
        [1185, 1098, 1184],
        
        [1099, 1098, 1183],
        [1183, 1098, 1184],
        
        [1100, 1099, 1182],
        [1099, 1183, 1182],
        
        [1101, 1100, 1182],
        [1181, 1101, 1182],
        
        [417, 1181, 1182],
        [132, 417, 1182],
        
        [132, 1182, 1186],
        
        [1080, 1079, 1170],
        
        [1079, 1078, 1170],
        [1170, 1078, 1171],
        
        [1078, 1077, 1171],
        [1171, 1077, 1172],
        
        [1077, 1076, 1173],
        [1077, 1173, 1172],
        
        [1076, 1075, 1174],
        [1174, 1173, 1076],
        
        [1075, 1074, 1174],
        [1174, 1074, 1175],
        
        [1074, 1073, 1176],
        [1176, 1175, 1074],
        
        [1073, 1072, 1176],
        [1176, 1072, 1177],
        
        [1072, 1071, 1178],
        [1178, 1177, 1072],
        
        [1071, 1070, 1179],
        [1179, 1071, 1178],
        
        [1070, 1069, 1179],
        [1069, 1180, 1179],
        
        [1180, 847, 1179],
        [847, 581, 1179],
        
        [1179, 581, 1175],


        
        
    ]
    
    
    let lowerLipIndices: [[Int32]] = [
        [22, 541, 21],
        [22, 671, 541],
        [671, 543, 541],
        [543, 671, 672],
        [545, 672, 673],
        [543, 672, 545],
        [557, 545, 673],
        [556, 557, 674],
        [674, 557, 673],
        [675, 556, 674],
        [553, 556, 675],
        [676, 553, 675],
        [676, 635, 553],
        [677, 635, 676],
        [677, 635, 826],
        [677, 825, 636],
        [677, 826, 635],
        [825, 826, 677],
        
        // MARK: - top lips, right, second layer
        [23, 671, 22],
        [23, 542, 671],
        [542, 672, 671],
        [542, 554, 672],
        [544, 546, 672],
        [546, 673, 672],
        [673, 546, 674],
        [546, 554, 674],
        [674, 554, 675],
        [554, 555, 675],
        [555, 676, 675],
        [555, 552, 676],
        [676, 552, 677],
        [552, 636, 677],
        [636, 825, 677],
        [824, 825, 636],
        
        // MARK: - top lips, right, third layer
        [23, 24, 542],
        [542, 24, 691],
        [691, 544, 542],
        [691, 690, 544],
        [544, 690, 689],
        [689, 546, 544],
        [689, 554, 546],
        [689, 688, 554],
        [554, 688, 555],
        [688, 687, 555],
        [555, 687, 552],
        [687, 686, 552],
        [552, 686, 636],
        [636, 685, 824],
        [824, 823, 638],
        [686, 685, 636],
        [823, 824, 685],
        [823, 684, 638],
        
        // MARK: - top lips, left, first layer
        [22, 21, 92],
        [92, 237, 22],
        [237, 92, 94],
        [238, 237, 94],
        [238, 94, 96],
        [239, 238, 96],
        [239, 96, 108],
        [239, 108, 240],
        [240, 108, 107],
        [240, 107, 241],
        [241, 107, 104],
        [241, 104, 242],
        [242, 104, 186],
        [242, 186, 243],
        [243, 186, 396],
        [243, 396, 395],
        [190, 395, 396],
        
        // MARK: - top lips, left, second layer
        [23, 22, 237],
        [237, 93, 23],
        [93, 237, 238],
        [95, 93, 238],
        [238, 97, 95],
        [97, 238, 239],
        [240, 97, 239],
        [240, 105, 97],
        [240, 241, 105],
        [105, 241, 106],
        [106, 241, 242],
        [242, 103, 106],
        [ 242, 243, 103],
        [243, 187, 103],
        [243, 395, 187],
        [187, 395, 394],
        
        // MARK: - top lips, left, third layer
        [24, 23, 93],
        [93, 256, 24],
        [256, 93, 95],
        [95, 255, 256],
        [255, 95, 254],
        [254, 95, 97],
        [254, 97, 105],
        [105, 253, 254],
        [253, 105, 106],
        [106, 252, 253],
        [252, 106, 103],
        [103, 251, 252],
        [103, 187, 251],
        [251, 187, 250],
        [250, 187, 394],
        [394, 393, 250],
        [189, 249, 393],
        [393, 394, 189],
        
        // MARK: - bottom lips, left, first layer
        [190, 1212, 247],
        [247, 248, 190],
        [1212, 123, 247],
        [248, 1212, 123],
        [123, 279, 275],
        [275, 247, 123],
        [279, 286, 290],
        [290, 275, 279],
        [286, 270, 274],
        [274, 290, 286],
        [270, 261, 265],
        [265, 274, 270],
        [261, 29, 25],
        [25, 265, 261],
        [29, 696, 700],
        [700, 25, 29],
        [696, 705, 709],
        [709, 700, 696],
        [705, 721, 725],
        [725, 709, 705],
        [721, 714, 710],
        [710, 725, 721],
        [714, 572, 682],
        [682, 710, 714],
        [572, 1208, 683],
        [683, 682, 572],
        [1208, 1207, 740],
        [740, 683, 1208],
        [1207, 837, 834],
        [834, 740, 1207],
        [837, 678, 684],
        [684, 834, 837],
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = ARSCNView(frame: self.view.bounds)
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
//                sceneView.debugOptions = [.showWireframe, .showBoundingBoxes, .showCreases, .showConstraints]
        view.addSubview(sceneView)
        
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
        
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 0, z: 10)
//        sceneView.scene.rootNode.addChildNode(lightNode)
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
//                node.geometry?.firstMaterial?.fillMode = .lines
        node.geometry?.firstMaterial?.transparency = 0.0
        
        if let eyeLashNode = loadEyelashesModel() {
            self.eyeLashNode = eyeLashNode
                         node.addChildNode(eyeLashNode)
        }
        
        
        addLowerLipSurface(to: node, from: faceAnchor)
        
//        updateEyelashPosition(from: faceAnchor)
        addEyelinerSurface(to: node, from: faceAnchor, triangles: eyelinerVerticesIndices)
        
        return node
    }
    
    
    
    
     func addEyelinerSurface(to node: SCNNode, from faceAnchor: ARFaceAnchor, triangles: [[Int32]]) {
         let vertices = faceAnchor.geometry.vertices.map { SCNVector3($0.x, $0.y, $0.z) }
         
         let vertexSource = SCNGeometrySource(vertices: vertices)
         
         var indices: [Int32] = []
         for triangle in triangles {
             indices.append(contentsOf: triangle)
         }
         
         let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
         let geometryElement = SCNGeometryElement(data: indexData,
                                                  primitiveType: .triangles,
                                                  primitiveCount: indices.count / 3,
                                                  bytesPerIndex: MemoryLayout<Int32>.size)
         
         let geometry = SCNGeometry(sources: [vertexSource], elements: [geometryElement])
         
         let material = SCNMaterial()
         material.diffuse.contents = UIColor.black.withAlphaComponent(0.95)
         material.isDoubleSided = true
         geometry.materials = [material]
         
         let eyelinerNode = SCNNode(geometry: geometry)
         node.addChildNode(eyelinerNode)
         self.eyelinerNode = eyelinerNode
     }
   
    func loadEyelashesModel() -> SCNNode? {
        guard let url = Bundle.main.url(forResource: "Eyelashes", withExtension: "usdz"),
              let modelNode = SCNReferenceNode(url: url) else {
            return nil
        }
        modelNode.load()
        
        let blackMaterial = SCNMaterial()
        blackMaterial.diffuse.contents = UIColor.black
        blackMaterial.emission.contents = UIColor.black
        
        if let geometry = modelNode.geometry {
            geometry.materials = [blackMaterial]
        } else {
            modelNode.enumerateChildNodes { (childNode, _) in
                childNode.geometry?.materials = [blackMaterial]
            }
        }
        
        return modelNode
    }
    
    func addLowerLipSurface(to node: SCNNode, from faceAnchor: ARFaceAnchor) {
        let vertices = faceAnchor.geometry.vertices.map { SCNVector3($0.x, $0.y, $0.z) }
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        
        var indices: [Int32] = []
        for triangle in lowerLipIndices {
            indices += triangle
        }
        
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let geometryElement = SCNGeometryElement(data: indexData,
                                                 primitiveType: .triangles,
                                                 primitiveCount: indices.count / 3,
                                                 bytesPerIndex: MemoryLayout<Int32>.size)
        
        let geometry = SCNGeometry(sources: [vertexSource], elements: [geometryElement])
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red.withAlphaComponent(0.7)
        material.isDoubleSided = true
        geometry.materials = [material]
        
        let lipNode = SCNNode(geometry: geometry)
        lipNode.renderingOrder = 200
        node.addChildNode(lipNode)
        lowerLipNode = lipNode
    }
    
    //    Update eyelashes model
    func updateEyelashPosition(from faceAnchor: ARFaceAnchor) {
        let vertices = faceAnchor.geometry.vertices
        
        let vertex56 = vertices[56]
        let vertex1179 = vertices[1179]
        
        let position56 = SCNVector3(vertex56.x, vertex56.y, vertex56.z)
        let position1179 = SCNVector3(vertex1179.x, vertex1179.y, vertex1179.z)
        
        let midPosition = SCNVector3(
            (position56.x + position1179.x) / 2,
            (position56.y + position1179.y) / 2,
            (position56.z + position1179.z) / 2
        )
        
        eyeLashNode?.position = midPosition
        
        let yOffset: Float = 0.02
        eyeLashNode?.position.y += yOffset
        
        let directionVector = SCNVector3(
            position1179.x - position56.x,
            0,
            position1179.z - position56.z
        )
        
        let angle = atan2(directionVector.z, directionVector.x)
        eyeLashNode?.eulerAngles = SCNVector3(0, angle, 0)
        
        let distance = simd_distance(vertex56, vertex1179)
        let originalLength: Float = 1.0
        let scaleFactor = distance / originalLength
        eyeLashNode?.scale = SCNVector3(0.001, 0.001, 0.001)
    }
    func updateEyelinerSurface(from faceAnchor: ARFaceAnchor, triangles: [[Int32]]) {
        guard let eyelinerNode = eyelinerNode else { return }
        
        let vertices = faceAnchor.geometry.vertices.map { SCNVector3($0.x, $0.y, $0.z) }
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        
        var indices: [Int32] = []
        for triangle in triangles {
            indices.append(contentsOf: triangle)
        }
        
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let geometryElement = SCNGeometryElement(data: indexData,
                                                 primitiveType: .triangles,
                                                 primitiveCount: indices.count / 3,
                                                 bytesPerIndex: MemoryLayout<Int32>.size)
        
        let geometry = SCNGeometry(sources: [vertexSource], elements: [geometryElement])
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black.withAlphaComponent(0.95)
        material.isDoubleSided = true
        geometry.materials = [material]
        
        eyelinerNode.geometry = geometry
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
            return
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
        
        updateLowerLipSurface(from: faceAnchor)
                updateEyelashPosition(from: faceAnchor)
        updateEyelinerSurface(from: faceAnchor, triangles: eyelinerVerticesIndices)
        
        
        
    }
    
    //    Update lips surface
    func updateLowerLipSurface(from faceAnchor: ARFaceAnchor) {
        guard let lowerLipNode = lowerLipNode else { return }
        
        let vertices = faceAnchor.geometry.vertices.map { SCNVector3($0.x, $0.y, $0.z) }
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        
        var indices: [Int32] = []
        for triangle in lowerLipIndices {
            indices += triangle
        }
        
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let geometryElement = SCNGeometryElement(data: indexData,
                                                 primitiveType: .triangles,
                                                 primitiveCount: indices.count / 3,
                                                 bytesPerIndex: MemoryLayout<Int32>.size)
        
        let geometry = SCNGeometry(sources: [vertexSource], elements: [geometryElement])
        
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = UIColor.red.withAlphaComponent(0.7)
        geometry.materials = [material]
        
        lowerLipNode.geometry = geometry
    }
}

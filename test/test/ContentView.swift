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
    // Kaşları çevreleyen noktaların indeksleri
      let leftEyebrowIndices: [Int] = [168, 420, 329, 328, 327, 326, 335, 197, 198, 326, 163, 161, 207, 170] // Örnek indeksler
      let rightEyebrowIndices: [Int] = [617, 850, 781, 764, 763, 762, 768, 646, 647, 650, 614, 613, 761, 612, 610, 656, 619] // Örnek indeksler
      
    
    let lowerLipIndices: [[Int32]] = [
        // MARK: - top lips, right, first layer
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
      
//      [407, 285, 275],
//      [285, 260, 265],
//      [290, 260, 265],

      [],
      
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
      [684, 834, 837]


      
      
      
      
      
        
        

    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = ARSCNView(frame: self.view.bounds)
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
//        sceneView.debugOptions = [.showWireframe, .showBoundingBoxes, .showCreases, .showConstraints]
        view.addSubview(sceneView)
        
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // Renderer başlangıcında yüz ve alt dudağı oluşturuluyor
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
        
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
//        node.geometry?.firstMaterial?.fillMode = .lines
        node.geometry?.firstMaterial?.transparency = 0.0
        
        addLowerLipSurface(to: node, from: faceAnchor)
        
        return node
    }
    
    // Alt dudağın yüzeyini ekleme
    func addLowerLipSurface(to node: SCNNode, from faceAnchor: ARFaceAnchor) {
        let vertices = faceAnchor.geometry.vertices.map { SCNVector3($0.x, $0.y, $0.z) }
        
        // SCNGeometrySource oluşturma
        let vertexSource = SCNGeometrySource(vertices: vertices)
        
        // Manuel olarak belirlenen üçgenler için index oluşturma
        var indices: [Int32] = []
        for triangle in lowerLipIndices {
            indices += triangle
        }
        
        // Geometrik element oluşturma
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let geometryElement = SCNGeometryElement(data: indexData,
                                                 primitiveType: .triangles,
                                                 primitiveCount: indices.count / 3,
                                                 bytesPerIndex: MemoryLayout<Int32>.size)
        
        // Geometriyi oluşturuyoruz ve malzemeyi ayarlıyoruz
        let geometry = SCNGeometry(sources: [vertexSource], elements: [geometryElement])
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red.withAlphaComponent(0.7) // Yarı saydam kırmızı
        material.isDoubleSided = true
        material.isDoubleSided = true // Her iki tarafta da görünür
        material.transparency = 1.0 // Tam şeffaflık yok, tamamen görünür
        material.lightingModel = .physicallyBased // Gerçekçi ışıklandırma modeli
        material.diffuse.contents = UIColor.white // Alternatif olarak beyaz bir renk ile test
        geometry.materials = [material]


        // Geometriyi node'a ekliyoruz
        let lipNode = SCNNode(geometry: geometry)
        lipNode.renderingOrder = 200
        node.addChildNode(lipNode)
        lowerLipNode = lipNode
    }

    // Renderer güncelleme sırasında alt dudağı güncelleme
    func renderer(
        _ renderer: SCNSceneRenderer,
        didUpdate node: SCNNode,
        for anchor: ARAnchor) {
            
            guard let faceAnchor = anchor as? ARFaceAnchor,
                  let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                return
            }
            faceGeometry.update(from: faceAnchor.geometry)
            updateLowerLipSurface(from: faceAnchor)
        }
    
    // Alt dudağı güncelleme
    func updateLowerLipSurface(from faceAnchor: ARFaceAnchor) {
        guard let lowerLipNode = lowerLipNode else { return }
        
        let vertices = faceAnchor.geometry.vertices.map { SCNVector3($0.x, $0.y, $0.z) }
        
        // SCNGeometrySource oluşturma
        let vertexSource = SCNGeometrySource(vertices: vertices)
        
        // Mevcut üçgenler için index oluşturma
        var indices: [Int32] = []
        for triangle in lowerLipIndices {
            indices += triangle
        }
        
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let geometryElement = SCNGeometryElement(data: indexData,
                                                 primitiveType: .triangles,
                                                 primitiveCount: indices.count / 3,
                                                 bytesPerIndex: MemoryLayout<Int32>.size)
        
        // SCNGeometry oluşturma
        let geometry = SCNGeometry(sources: [vertexSource], elements: [geometryElement])
        
        // Malzeme ayarlama
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.isDoubleSided = true // Her iki tarafta da görünür
        material.transparency = 1.0 // Tam şeffaflık yok, tamamen görünür
        material.lightingModel = .physicallyBased // Gerçekçi ışıklandırma modeli
        material.diffuse.contents = UIColor.white // Alternatif olarak beyaz bir renk ile test

        material.diffuse.contents = UIColor.red.withAlphaComponent(0.7) // Yarı saydam kırmızı
        geometry.materials = [material]
        
        
        // Mevcut geometry'i güncellemek yerine yeni geometry atama
        lowerLipNode.geometry = geometry
    }
}

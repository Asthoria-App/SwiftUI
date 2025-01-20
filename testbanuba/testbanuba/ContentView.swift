//
//  ContentView.swift
//  testbanuba
//
//  Created by Aysema Çam on 27.11.2024.
//

import SwiftUI
import BNBSdkApi
import BNBSdkCore

class BanubaCameraManager {
    static let shared = BanubaCameraManager()
    
    private var player: Player?
    private var cameraDevice: CameraDevice?
    private var effect: BNBEffect?
    
    private init() {
        setupPlayer()
    }
    
    private func setupPlayer() {
        cameraDevice = CameraDevice(cameraMode: .FrontCameraSession, captureSessionPreset: .hd1280x720)
        player = Player()
        
        if let player = player, let cameraDevice = cameraDevice {
            player.use(input: Camera(cameraDevice: cameraDevice))
            cameraDevice.start()
        }
    }
    
    func attachEffect(to effectView: EffectPlayerView, effectName: String) {
        guard let player = player else { return }

        let effectsPath = Bundle.main.bundlePath + "/Graduate"
        let effectFullPath = "\(effectsPath)/\(effectName)"
        if !FileManager.default.fileExists(atPath: effectFullPath) {
            print("Effect \(effectName) not found at path \(effectFullPath)")
            return
        }

        player.use(outputs: [effectView])
        effect = player.load(effect: effectName)

        if effect == nil {
            print("Effect \(effectName) failed to load.")
        } else {
            print("Effect \(effectName) loaded successfully.")
        }
    }

    
    func stopCamera() {
        cameraDevice?.stop()
        player?.use(input: nil)
        player?.use(outputs: [])
    }
}

struct BanubaCameraView: UIViewControllerRepresentable {
    let effectName: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let effectView = EffectPlayerView()
        effectView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(effectView)
        
        NSLayoutConstraint.activate([
            effectView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            effectView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            effectView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        
        DispatchQueue.main.async {
            BanubaCameraManager.shared.attachEffect(to: effectView, effectName: effectName)
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct ContentView: View {
    @State private var isCameraActive = false
    
    var body: some View {
        VStack {
            if isCameraActive {
                BanubaCameraView(effectName: "Graduate")
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Tap to start camera")
                    .padding()
            }
            
            Button(action: {
                if isCameraActive {
                    BanubaCameraManager.shared.stopCamera()
                }
                isCameraActive.toggle()
            }) {
                Text(isCameraActive ? "Stop Camera" : "Start Camera")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
    }
}



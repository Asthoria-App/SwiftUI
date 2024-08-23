//
//  ContentView.swift
//  banuba_sample
//
//  Created by Aysema Holding on 23.08.2024.
//

import SwiftUI
import AVFoundation
import BNBSdkApi
import BNBSdkCore
import AgoraRtcKit

internal let agoraAppID = "fbf0eef5753c46d3bb7704573df7a107"
internal let agoraClientToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ODksImlhdCI6MTcyNDAwMzQ4MSwiZXhwIjoxNzI2NTk1NDgxfQ.Axf7D9EHFTdw8exqDwvWTvoS2H6f13X6HJr8M-XfJIk"
internal let agoraChannelId = "366c7950f0bbc4183dffc4750"

struct ContentView: View {
    @StateObject private var viewModel = MainScreenViewModel()
    
    var body: some View {
        VStack {
            CameraView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.effects, id: \.effectName) { effect in
                        EffectPreviewView(effect: effect)
                            .onTapGesture {
                                viewModel.didSelectEffect(with: effect)
                            }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.requestCameraPermissionIfNeeded()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Kamera Erişimi Reddedildi"),
                message: Text("Lütfen kamera erişimine izin verin."),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
}


struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: MainScreenViewModel
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraVC = CameraViewController(viewModel: viewModel)
        return cameraVC
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
       
    }
}

struct EffectPreviewView: View {
    let effect: EffectConfig
    
    var body: some View {
        VStack {
            Image(systemName: "camera")
                .resizable()
                .frame(width: 50, height: 50)
                .padding()
            
            Text(effect.effectName)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.gray)
        .cornerRadius(10)
    }
}

class CameraViewController: UIViewController {
    private let viewModel: MainScreenViewModel
    private var effectPlayerView: EffectPlayerView!
    
    init(viewModel: MainScreenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEffectPlayerView()
        viewModel.startCameraSession()
    }
    
    private func setupEffectPlayerView() {

        effectPlayerView = EffectPlayerView(frame: view.bounds)
        view.addSubview(effectPlayerView)

        let sdkManager = BanubaSdkManager()
        sdkManager.setRenderTarget(view: effectPlayerView, playerConfiguration: nil)
        sdkManager.startEffectPlayer()
    }
}

final class MainScreenViewModel: ObservableObject {
    @Published var effects = EffectsFactory.arVideoCallEffects
    @Published var selectedEffect: EffectConfig? = nil
    @Published var showAlert = false
    
    private let player: Player
    private let cameraDevice: CameraDevice
    private let sdkManager: BanubaSdkManager
    private let agoraKit: AgoraRtcEngineKit
    
    init() {
        player = Player()
        cameraDevice = CameraDevice(cameraMode: .FrontCameraSession, captureSessionPreset: .hd1280x720)
        sdkManager = BanubaSdkManager()
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: agoraAppID, delegate: nil)
        setupAgora()
    }
    
    func requestCameraPermissionIfNeeded() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.startCameraSession()
                    } else {
                        self?.showAlert = true
                    }
                }
            }
        case .authorized:
            startCameraSession()
        default:
            showAlert = true
        }
    }
    
    func startCameraSession() {
        cameraDevice.start()
        sdkManager.startEffectPlayer()
    }
    
    func didSelectEffect(with effect: EffectConfig) {
        selectedEffect = effect
        loadEffect(effect)
    }
    
    private func loadEffect(_ effect: EffectConfig) {
        Task {
            await player.loadEffect(effect.effectName)
        }
    }

    private func setupAgora() {
        agoraKit.delegate = self
        agoraKit.enableVideo()
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.setClientRole(.broadcaster)
        
        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(
            size: AgoraVideoDimension1280x720,
            frameRate: .fps30,
            bitrate: AgoraVideoBitrateStandard,
            orientationMode: .adaptative, mirrorMode: .auto
        ))
    }
}


extension MainScreenViewModel: AgoraRtcEngineDelegate {
    
    func isEqual(_ object: Any?) -> Bool {
        return false // Default implementation
    }
    
    var hash: Int {
        return 0 // Default implementation
    }
    
    var superclass: AnyClass? {
        return nil // Default implementation
    }
    
    func `self`() -> Self {
        return self // This just returns the current instance
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        return nil // Not typically used in Swift
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        return nil // Not typically used in Swift
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        return nil // Not typically used in Swift
    }
    
    func isProxy() -> Bool {
        return false // Default implementation
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        return false // Default implementation
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        return false // Default implementation
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        return false // Default implementation, could be set to true if needed
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        return false // Default implementation
    }
    
    var description: String {
        return "MainScreenViewModel" // Default description, modify as needed
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        // Handle when a remote user joins
    }
}


struct EffectConfig: Identifiable, Equatable {
    var id: String { effectName }
    let effectName: String
    let preview: EffectPreview
    
    static func == (lhs: EffectConfig, rhs: EffectConfig) -> Bool {
        return lhs.effectName == rhs.effectName
    }
}

enum EffectPreview {
    case uniqueIcon(named: String)
    case color(hex: String)
    case templatedIcon(named: String, letter: String)
    case fromEffect(pathToEffect: String)
    case none
}

class EffectsFactory {
    static let arVideoCallEffects: [EffectConfig] = [
        EffectConfig(effectName: "CubemapEverest", preview: .templatedIcon(named: "360_backgrounds", letter: "A")),
        EffectConfig(effectName: "RainbowBeauty", preview: .uniqueIcon(named: "rainbow_beauty")),
        EffectConfig(effectName: "RegularDawnOfNature", preview: .templatedIcon(named: "regular_background", letter: "A")),
        EffectConfig(effectName: "Sunset", preview: .templatedIcon(named: "color_correction", letter: "A")),
        EffectConfig(effectName: "CartoonOctopus", preview: .uniqueIcon(named: "cartoon_octopus"))
    ]
}

fileprivate extension Player {
    @discardableResult
    func loadEffect(_ name: String) async -> BNBEffect? {
        await withCheckedContinuation { continuation in
            let effect = load(effect: name, sync: true)
            continuation.resume(returning: effect)
        }
    }
}

import SwiftUI
import AVKit
import UIKit
import PencilKit
import AVFoundation
import AVKit


enum BackgroundType {
    case photo
    case video
}

struct StoryEditView: View {
    @State private var showDeleteButton: Bool = false
    @State private var showOverlay: Bool = false
    @State private var hideButtons: Bool = false
    @State private var textColor: Color = .white
    @State private var backgroundOpacity: CGFloat = 0.0
    @State private var selectedFont: CustomFont = .roboto
    @State private var showBackgroundImagePicker: Bool = false
    @State private var showDraggableImagePicker: Bool = false
    @State private var backgroundImage: UIImage? = nil
    @State private var selectedDraggableImage: UIImage? = nil
    @State private var selectedGradient: LinearGradient? = nil
    @State private var textBackgroundColor: Color = .clear
    @State private var originalTextColor: Color = .clear
    @State private var generatedImage: UIImage? = nil
    @State private var showGeneratedImageView: Bool = false
    @State private var fontSize: CGFloat = 34
    @State private var draggableTexts: [DraggableText] = []
    @State private var selectedTextIndex: Int? = nil
    @State private var draggableImages: [DraggableImage] = []
    @State private var selectedImageIndex: Int? = nil
    @State private var showStickerPicker: Bool = false
    @State private var draggableStickers: [DraggableSticker] = []
    @State private var selectedStickerImage: UIImage? = nil
    @State private var globalIndex: CGFloat = 1
    @State private var showDrawingOverlay: Bool = false
    @State private var draggableDrawings: [DraggableDrawing] = []
    @State private var selectedDrawingIndex: Int? = nil
    @State private var backgroundType: BackgroundType = .video
        @State private var exportedVideoURL: URL? = URL(string: "https://videos.pexels.com/video-files/853889/853889-hd_1920_1080_25fps.mp4")
//    @State private var exportedVideoURL: URL? = URL(string: "https://cdn.pixabay.com/video/2020/06/30/43459-436106182_small.mp4")
    
    
    @State private var processedVideoURL: URL? = nil
    @State private var selectedEffect: EffectType? = nil
    
    
    @State private var showFullScreenPlayer: Bool = false
    
    let gradientOptions: [LinearGradient] = [
        LinearGradient(gradient: Gradient(colors: [.blue, .blue]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [.green, .yellow]), startPoint: .top, endPoint: .bottom)
    ]
    private func getVideoFrame() -> CGRect? {
        guard let videoURL = exportedVideoURL else {
            return nil
        }
        
        let asset = AVAsset(url: videoURL)
        guard let track = asset.tracks(withMediaType: .video).first else {
            return nil
        }
        
        let videoSize = track.naturalSize
        let transform = track.preferredTransform
        
        let isPortrait = transform.a == 0 && transform.d == 0 && (transform.b == 1.0 || transform.b == -1.0)
        
        let correctedVideoSize = isPortrait ? CGSize(width: videoSize.height, height: videoSize.width) : videoSize
        
        let screenSize = UIScreen.main.bounds.size
        let videoFrame: CGRect
        
        if correctedVideoSize.width / correctedVideoSize.height > screenSize.width / screenSize.height {
            let height = screenSize.width * correctedVideoSize.height / correctedVideoSize.width
            videoFrame = CGRect(x: 0, y: (screenSize.height - height) / 2, width: screenSize.width, height: height)
        } else {
            let width = screenSize.height * correctedVideoSize.width / correctedVideoSize.height
            videoFrame = CGRect(x: (screenSize.width - width) / 2, y: 0, width: width, height: screenSize.height)
        }
        
        return videoFrame
    }
    
    var body: some View {
        ZStack {
            switch backgroundType {
            case .photo:
                if let backgroundImage = backgroundImage {
                    Image(uiImage: backgroundImage)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                } else if let selectedGradient = selectedGradient {
                    selectedGradient
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Image("image")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                }
            case .video:
                if let processedVideoURL = processedVideoURL {
                    FullScreenVideoPlayerView(videoURL: processedVideoURL, selectedEffect: $selectedEffect, hideButtons: $hideButtons)
                        .edgesIgnoringSafeArea(.all)
                }
                else if let exportedVideoURL = exportedVideoURL {
                    FullScreenVideoPlayerView(videoURL: exportedVideoURL, selectedEffect: $selectedEffect, hideButtons: $hideButtons)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            
            ForEach(draggableDrawings.indices, id: \.self) { index in
                DraggableDrawingView(draggableDrawing: $draggableDrawings[index], selectedDrawingIndex: $selectedDrawingIndex, index: index, hideButtons: $hideButtons)
                    .zIndex(draggableDrawings[index].zIndex)
            }
            
            ForEach(draggableImages.indices, id: \.self) { index in
                DraggableImageView(draggableImage: $draggableImages[index], selectedImageIndex: $selectedImageIndex, index: index, hideButtons: $hideButtons)
                    .frame(width: 200, height: 200)
                    .aspectRatio(contentMode: .fill)
                    .zIndex(draggableImages[index].zIndex)
                    .onAppear {
                        print("Image Position: \(draggableImages[index].position), Image Size: \(draggableImages[index].image.size)")
                    }
            }
            
            ForEach(draggableStickers.indices, id: \.self) { index in
                DraggableStickerView(draggableSticker: $draggableStickers[index], hideButtons: $hideButtons, deleteArea: CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height - 100, width: 100, height: 100), onDelete: {
                    draggableStickers.remove(at: index)
                })
                .frame(width: 100, height: 100)
                .zIndex(draggableStickers[index].zIndex)
                .onAppear {
                    print(draggableStickers[index].globalFrame, "frame in editview")
                }
            }
            
            ForEach(draggableTexts.indices, id: \.self) { index in
                DraggableTextView(
                    userText: $draggableTexts[index].text,
                    textPosition: $draggableTexts[index].position,
                    scale: $draggableTexts[index].scale,
                    angle: $draggableTexts[index].angle,
                    showDeleteButton: $showDeleteButton,
                    hideButtons: $hideButtons,
                    showOverlay: $showOverlay,
                    textColor: $draggableTexts[index].textColor,
                    backgroundColor: $draggableTexts[index].backgroundColor,
                    backgroundOpacity: $draggableTexts[index].backgroundOpacity,
                    selectedFont: $draggableTexts[index].font,
                    fontSize: $draggableTexts[index].fontSize,
                    index: index,
                    selectedTextIndex: $selectedTextIndex
                )
                .zIndex(draggableTexts[index].zIndex)
                .onAppear {
                    print("Text Position: \(draggableTexts[index].position), Text Size: \(draggableTexts[index].fontSize)")
                }
            }
            if !showDrawingOverlay && !hideButtons {
                GeometryReader { geometry in
                    AdditionalButtonsView(addTimeImage: addTimeImageToView)
                        .frame(width: 100)
                        .position(x: geometry.size.width - 30,
                                  y: geometry.size.height / 2)
                }
                .zIndex(100)
            }

            
            
            if !showDrawingOverlay {
                VStack {
                    if !hideButtons {
                        HStack {
                            Button(action: {
                                showBackgroundImagePicker = true
                            }) {
                                Image(systemName: "wallet.pass.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 35, height: 35)
                            .shadow(color: .gray.opacity(0.8), radius: 5, x: 0, y: 5)

                            .padding(.leading, 15)
                            
                            Spacer()
                            
                            Button(action: {
                                showStickerPicker = true
                            }) {
                                Image(systemName: "face.smiling.inverse")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 35, height: 35)
                            .shadow(color: .gray.opacity(0.8), radius: 5, x: 0, y: 5)

                            
                            Button(action: {
                                hideButtons = true
                                showDrawingOverlay = true
                            }) {
                                Image(systemName: "pencil.and.scribble")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 35, height: 35)
                            .shadow(color: .gray.opacity(0.8), radius: 5, x: 0, y: 5)

                            
                            Button(action: {
                                let newText = DraggableText(
                                    text: "New Text",
                                    position: .zero,
                                    scale: 1.0,
                                    angle: .zero,
                                    textColor: textColor,
                                    backgroundColor: textBackgroundColor,
                                    backgroundOpacity: backgroundOpacity,
                                    font: selectedFont,
                                    fontSize: fontSize,
                                    zIndex: globalIndex
                                )
                                globalIndex += 1
                                draggableTexts.append(newText)
                                selectedTextIndex = draggableTexts.count - 1
                                showOverlay = true
                                textColor = .white
                            }) {
                                Image(systemName: "textformat")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 35, height: 35)
                            .shadow(color: .gray.opacity(0.8), radius: 5, x: 0, y: 5)
                            
                            Button(action: {
                                showDraggableImagePicker = true
                            }) {
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 35, height: 35)
                            .shadow(color: .gray.opacity(0.8), radius: 5, x: 0, y: 5)
                            .padding(.trailing, 15)
                        }
                        
                        .frame(width: UIScreen.main.bounds.width)
                        
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                    
                    if  !hideButtons && !showOverlay {
                        VStack {
                            Spacer()
                            Button("Done") {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    if let videoFrame = getVideoFrame() {
                                        processVideo(videoFrame: videoFrame)
                                    } else {
                                        print("Video frame could not be determined")
                                    }
                                }
                            }
                            .font(.title2)
                            .padding()
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                            
                        }
                    }
                    
                    if hideButtons && !showOverlay {
                        VStack {
                            Spacer()
                            Button(action: {
                                
                            }) {
                                Image(systemName: "trash")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 35, height: 35)
                            .transition(.scale)
                            .animation(.easeInOut(duration: 0.3), value: showDeleteButton)
                            .padding(12)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                            .padding(.bottom, 20)
                        }
                    }
                }
                .zIndex(100)
            }
            
            if showDrawingOverlay {
                GeometryReader { geometry in
                    DrawingOverlay(showDrawingOverlay: $showDrawingOverlay, hideButtons: $hideButtons) { drawingImage, drawingRect in
                        if let image = drawingImage, let rect = drawingRect {
                            globalIndex += 1
                            
                            let adjustedRect = CGRect(
                                x: rect.origin.x + geometry.frame(in: .global).origin.x,
                                y: rect.origin.y + geometry.frame(in: .global).origin.y,
                                width: rect.width,
                                height: rect.height
                            )
                            
                            let newDraggableDrawing = DraggableDrawing(
                                image: image,
                                position: adjustedRect,
                                scale: 1.0,
                                angle: .zero,
                                zIndex: globalIndex
                            )
                            
                            draggableDrawings.append(newDraggableDrawing)
                            selectedDrawingIndex = draggableDrawings.count - 1
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .zIndex(100)
            }
            
            if showOverlay, let selectedIndex = selectedTextIndex {
                OverlayView(
                    showOverlay: $showOverlay,
                    userText: $draggableTexts[selectedIndex].text,
                    textColor: $draggableTexts[selectedIndex].textColor,
                    backgroundColor: $draggableTexts[selectedIndex].backgroundColor,
                    backgroundOpacity: $draggableTexts[selectedIndex].backgroundOpacity,
                    selectedFont: $draggableTexts[selectedIndex].font,
                    originalTextColor: $originalTextColor,
                    fontSize: $draggableTexts[selectedIndex].fontSize,
                    onChange: {
                        draggableTexts[selectedIndex].originalTextColor = originalTextColor
                        draggableTexts[selectedIndex].textColor = textColor
                        draggableTexts[selectedIndex].backgroundColor = textBackgroundColor
                        draggableTexts[selectedIndex].backgroundOpacity = backgroundOpacity
                        draggableTexts[selectedIndex].font = selectedFont
                        draggableTexts[selectedIndex].fontSize = fontSize
                    }
                )
                .zIndex(100)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showBackgroundImagePicker) {
            GradientImagePickerView(gradients: gradientOptions, selectedGradient: $selectedGradient, selectedImage: $backgroundImage, showBackgroundImagePicker: $showBackgroundImagePicker)
        }
        
        .fullScreenCover(isPresented: $showFullScreenPlayer) {
            SimpleVideoPlayerView(videoURL: processedVideoURL!)
                .edgesIgnoringSafeArea(.all)
            
        }
        
        .sheet(isPresented: $showDraggableImagePicker) {
            ImagePicker(selectedImage: $selectedDraggableImage)
                .onDisappear {
                    if let selectedImage = selectedDraggableImage {
                        globalIndex += 1
                        let newImage = DraggableImage(image: selectedImage, position: .zero, scale: 1.0, angle: .zero, zIndex: globalIndex)
                        draggableImages.append(newImage)
                        selectedImageIndex = draggableImages.count - 1
                        selectedDraggableImage = nil
                    }
                }
        }
        
        .sheet(isPresented: $showStickerPicker) {
            BottomSheetStickerPickerView(selectedStickerImage: $selectedStickerImage)
                .onDisappear {
                    if let selectedStickerImage = selectedStickerImage {
                        globalIndex += 1
                        let newSticker = DraggableSticker(image: selectedStickerImage, position: .zero, scale: 1.0, angle: .zero, zIndex: globalIndex)
                        draggableStickers.append(newSticker)
                        self.selectedStickerImage = nil
                    }
                }
        }
        .sheet(isPresented: $showGeneratedImageView) {
            GeneratedImageView(image: generatedImage)
        }
        .onChange(of: showOverlay) { newValue in
            hideButtons = newValue
        }
    }
    
    private func generateImageFromPhoto() {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let renderer = UIGraphicsImageRenderer(bounds: window!.bounds)
        generatedImage = renderer.image { context in
            window?.layer.render(in: context.cgContext)
        }
        showGeneratedImageView = true
    }
    
    private func processVideo(videoFrame: CGRect) {
        guard let videoURL = exportedVideoURL else {
            print("Video URL not found")
            return
        }
        
        let overlayImage = generateOverlayImage(videoFrame: videoFrame, selectedEffect: selectedEffect)
        
        if let effect = selectedEffect {
            switch effect {
            case .monochrome:
                
                let videoProcessor = VideoProcessor(videoURL: videoURL, overlayImage: overlayImage)
                videoProcessor.processVideo { url in
                    DispatchQueue.main.async {
                        self.processedVideoURL = url
                        if let processedURL = url {
                            self.showProcessedVideo(processedURL: processedURL)
                            self.showFullScreenPlayer = true
                        }
                    }
                }
            case .color:
                let videoProcessor = VideoProcessor(videoURL: videoURL, overlayImage: overlayImage)
                videoProcessor.processVideo { url in
                    DispatchQueue.main.async {
                        self.processedVideoURL = url
                        if let processedURL = url {
                            self.showProcessedVideo(processedURL: processedURL)
                            self.showFullScreenPlayer = true
                        }
                    }
                }
            }
        } else {
            let videoProcessor = VideoProcessor(videoURL: videoURL, overlayImage: overlayImage)
            videoProcessor.processVideo { url in
                DispatchQueue.main.async {
                    self.processedVideoURL = url
                    if let processedURL = url {
                        self.showProcessedVideo(processedURL: processedURL)
                        self.showFullScreenPlayer = true
                    }
                }
            }
        }
    }
    
    
    
    private func showProcessedVideo(processedURL: URL) {
        self.processedVideoURL = processedURL
    }
    
    private func generateOverlayImage(videoFrame: CGRect, selectedEffect: EffectType?) -> UIImage {
        let screenSize = UIScreen.main.bounds.size
        UIGraphicsBeginImageContextWithOptions(screenSize, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        
        var allElements: [(image: UIImage?, text: NSAttributedString?, rect: CGRect, angle: CGFloat, zIndex: CGFloat)] = []
        
        for sticker in draggableStickers {
            allElements.append((image: sticker.image, text: nil, rect: sticker.globalFrame, angle: sticker.angle.radians, zIndex: sticker.zIndex))
        }
        
        for image in draggableImages {
            allElements.append((image: image.image, text: nil, rect: image.globalFrame, angle: image.angle.radians, zIndex: image.zIndex))
        }
        
        for drawing in draggableDrawings {
            allElements.append((image: drawing.image, text: nil, rect: drawing.position, angle: drawing.angle.radians, zIndex: drawing.zIndex))
        }
        
        for text in draggableTexts {
            let scaledFontSize = text.fontSize * text.scale
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: text.font.toUIFont(size: scaledFontSize)!,
                .foregroundColor: UIColor(text.textColor)
            ]
            let attributedString = NSAttributedString(string: text.text, attributes: textAttributes)
            let textSize = attributedString.size()
            let rect = CGRect(
                origin: CGPoint(x: text.position.width + screenSize.width / 2 - textSize.width / 2,
                                y: text.position.height + screenSize.height / 2 - textSize.height / 2),
                size: textSize
            )
            allElements.append((image: nil, text: attributedString, rect: rect, angle: text.angle.radians, zIndex: text.zIndex))
        }
        
        allElements.sort { $0.zIndex < $1.zIndex }
        
        if let selectedEffect = selectedEffect {
            if case .color(let colorOverlay) = selectedEffect {
                context?.setFillColor(UIColor(colorOverlay).withAlphaComponent(0.1).cgColor)
                context?.fill(CGRect(origin: .zero, size: screenSize))
            }
        }
        
        for element in allElements {
            let rect = element.rect
            context?.saveGState()
            
            context?.translateBy(x: rect.midX, y: rect.midY)
            context?.rotate(by: element.angle)
            context?.translateBy(x: -rect.midX, y: -rect.midY)
            
            if let image = element.image {
                let path = UIBezierPath(roundedRect: rect, cornerRadius: 7)
                path.addClip()
                
                let imageSize = image.size
                let aspectWidth = rect.width / imageSize.width
                let aspectHeight = rect.height / imageSize.height
                let aspectRatio = max(aspectWidth, aspectHeight)
                
                let newWidth = imageSize.width * aspectRatio
                let newHeight = imageSize.height * aspectRatio
                let drawRect = CGRect(
                    x: rect.midX - newWidth / 2,
                    y: rect.midY - newHeight / 2,
                    width: newWidth,
                    height: newHeight
                )
                
                image.draw(in: drawRect)
            }
            
            if let text = element.text {
                UIColor.clear.setFill()
                text.draw(in: rect)
            }
            
            context?.restoreGState()
        }
        
        let composedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return composedImage ?? UIImage()
    }
}

import SwiftUI

struct AdditionalButtonsView: View {
    var addTimeImage: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(spacing: 12) {
                Button(action: {
                    print("Tag Button clicked")
                }) {
                    Image(systemName: "tag")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .padding(10)
                }
                .shadow(color: .gray.opacity(0.8), radius: 5, x: 0, y: 5)
                
                Button(action: {
                    addTimeImage() // Time butonuna basılınca image ekle
                }) {
                    Image(systemName: "clock")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .padding(10)
                }
                .shadow(color: .gray.opacity(0.8), radius: 5, x: 0, y: 5)
                
                Button(action: {
                    print("Location Button clicked")
                }) {
                    Image(systemName: "location")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .padding(10)
                }
                .shadow(color: .gray.opacity(0.8), radius: 5, x: 0, y: 5)
            }
        }
        .padding()
    }
}

extension StoryEditView {
    private func addTimeImageToView() {
        let currentTime = getCurrentTimeAsImage()
        
        let newDraggableImage = DraggableImage(image: currentTime, position: .zero, scale: 1.0, angle: .zero, zIndex: globalIndex)
        globalIndex += 1
        draggableImages.append(newDraggableImage)
        selectedImageIndex = draggableImages.count - 1
    }

    private func getCurrentTimeAsImage() -> UIImage {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let currentTimeString = dateFormatter.string(from: Date())
        
        let label = UILabel()
        label.text = currentTimeString
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.sizeToFit()
        label.frame = CGRect(x: 0, y: 0, width: label.frame.width + 20, height: label.frame.height + 10)
        
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
}












































struct GeneratedImageView: View {
    var image: UIImage?
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
            
                .resizable()
                .aspectRatio(contentMode: .fit)
                .edgesIgnoringSafeArea(.all)
        } else {
            Text("No image generated")
        }
    }
}

struct FullScreenVideoPlayerView: View {
    var videoURL: URL
    
    @State private var player = AVPlayer()
    @Binding var selectedEffect: EffectType?
    @Binding var hideButtons: Bool
    
    var body: some View {
        VStack {
            VideoPlayerContainer(player: player, selectedEffect: $selectedEffect)
                .onAppear {
                    setupPlayer()
                    player.play()
                }
                .onDisappear {
                    player.pause()
                    NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
                }
                .edgesIgnoringSafeArea(.all)
            
            if !hideButtons {
                EffectSelectionView(selectedEffect: $selectedEffect)
                    .frame(height: 100)
            }
        }
    }
    
    private func setupPlayer() {
        let playerItem = AVPlayerItem(url: videoURL)
        player.replaceCurrentItem(with: playerItem)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
        }
    }
}

struct VideoPlayerContainer: UIViewControllerRepresentable {
    var player: AVPlayer
    
    @Binding var selectedEffect: EffectType?
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = UIScreen.main.bounds
        
        let containerView = UIView(frame: UIScreen.main.bounds)
        containerView.layer.addSublayer(playerLayer)
        
        controller.view = containerView
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let playerLayer = uiViewController.view.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = UIScreen.main.bounds
        }
        
        uiViewController.view.subviews.forEach { $0.removeFromSuperview() }
        
        if let selectedEffect = selectedEffect {
            switch selectedEffect {
            case .color(let color):
                resetVideoCompositionIfNeeded()
                
                let overlayView = UIView(frame: UIScreen.main.bounds)
                overlayView.backgroundColor = UIColor(color)
                overlayView.alpha = 0.1
                uiViewController.view.addSubview(overlayView)
                
            case .monochrome:
                if let currentPlayerItem = player.currentItem {
                    let filter = CIFilter(name: "CIColorMonochrome")
                    filter?.setValue(CIColor(color: .white), forKey: kCIInputColorKey)
                    filter?.setValue(1.0, forKey: kCIInputIntensityKey)
                    
                    let videoComposition = AVVideoComposition(asset: currentPlayerItem.asset) { request in
                        let source = request.sourceImage.clampedToExtent()
                        filter?.setValue(source, forKey: kCIInputImageKey)
                        
                        if let output = filter?.outputImage {
                            let croppedOutput = output.cropped(to: request.sourceImage.extent)
                            request.finish(with: croppedOutput, context: nil)
                        } else {
                            request.finish(with: request.sourceImage, context: nil)
                        }
                    }
                    currentPlayerItem.videoComposition = videoComposition
                }
            }
        }
    }
    
    private func resetVideoCompositionIfNeeded() {
        if let currentPlayerItem = player.currentItem {
            currentPlayerItem.videoComposition = nil
        }
    }
}


struct EffectButton: View {
    var effectType: EffectType
    @Binding var selectedEffect: EffectType?
    
    var body: some View {
        Button(action: {
            selectedEffect = effectType
        }) {
            ZStack {
                Image(imageName(for: effectType))
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                
                
                Circle()
                    .stroke(selectedEffect == effectType ? Color.blue : Color.white, lineWidth: 2)
            }
            .frame(width: 56, height: 56)
        }
    }
    
    private func imageName(for effect: EffectType) -> String {
        switch effect {
        case .color(.red): return "view"
        case .color(.blue): return "view2"
        case .color(.purple): return "view3"
        case .color(.brown): return "view4"
        case .color(.cyan): return "view"
        default: return "view2"
        }
    }
}

struct EffectSelectionView: View {
    @Binding var selectedEffect: EffectType?
    let effects: [EffectType] = [.color(.red), .color(.blue), .color(.purple), .color(.brown), .color(.cyan), .monochrome]
    
    @State private var currentIndex: Int = 0
    @State private var scrollOffset: CGFloat = 0.0
    @State private var dragOffset: CGFloat = 0.0
    
    let buttonWidth: CGFloat = 86
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollViewReader { scrollViewProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 30) {
                            ForEach(effects.indices, id: \.self) { index in
                                VStack {
                                    EffectButton(effectType: effects[index], selectedEffect: $selectedEffect)
                                        .frame(width: 56, height: 56)
                                        .padding(.top, 10)
                                    
                                    Text(effects[index].name)
                                        .font(.caption)
                                        .foregroundColor(selectedEffect == effects[index] ? Color.blue : Color.white)
                                }
                            }
                        }
                        .padding(.horizontal, (geometry.size.width - buttonWidth) / 2)
                        .offset(x: scrollOffset + dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation.width
                                }
                                .onEnded { value in
                                    dragOffset = 0
                                    let totalOffset = scrollOffset + value.translation.width
                                    let snapIndex = Int(round(totalOffset / buttonWidth))
                                    let nearestIndex = min(max(currentIndex - snapIndex, 0), effects.count - 1)
                                    currentIndex = nearestIndex
                                    withAnimation(.easeOut) {
                                        scrollOffset = -CGFloat(currentIndex) * 56
                                    }
                                }
                        )
                    }
                    
                    .onAppear {
                        withAnimation(.easeOut) {
                            scrollOffset = -CGFloat(currentIndex) * buttonWidth
                        }
                    }
                }
            }
            .frame(height: 190)
            
            
        }
        .background(Color.black.opacity(0.5))
    }
}

enum EffectType: Hashable, Equatable {
    case color(Color)
    case monochrome
    
    var description: String {
        switch self {
        case .color(let color):
            return "Color: \(color.description.capitalized)"
        case .monochrome:
            return "Monochrome"
        }
    }
    
    var name: String {
        switch self {
        case .color(.red): return "Red"
        case .color(.blue): return "Blue"
        case .color(.purple): return "Purple"
        case .color(.brown): return "Brown"
        case .color(.cyan): return "Cyan"
        case .monochrome: return "Monochrome"
        default: return "None"
        }
    }
}




struct SimpleVideoPlayerView: UIViewControllerRepresentable {
    var videoURL: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        let player = AVPlayer(url: videoURL)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        playerViewController.player = player
        playerViewController.videoGravity = .resizeAspectFill
        
        playerViewController.showsPlaybackControls = false
        player.play()
        return playerViewController
    }
    
    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
    }
    
    static func dismantleUIViewController(_ playerViewController: AVPlayerViewController, coordinator: ()) {
        NotificationCenter.default.removeObserver(playerViewController, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}

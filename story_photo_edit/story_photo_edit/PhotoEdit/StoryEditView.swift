import SwiftUI
import AVKit
import UIKit
import PencilKit
import AVFoundation

enum DraggableType {
    case text, image, sticker, drawing
}
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
    @State private var processedVideoURL: URL? = nil
    
    let gradientOptions: [LinearGradient] = [
        LinearGradient(gradient: Gradient(colors: [.blue, .blue]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [.green, .yellow]), startPoint: .top, endPoint: .bottom)
    ]
    private func getVideoFrame() -> CGRect? {
        guard let videoURL = exportedVideoURL else {
            print("Video URL not found")
            return nil
        }
        
        let asset = AVAsset(url: videoURL)
        guard let track = asset.tracks(withMediaType: .video).first else {
            print("No video track found")
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
                    FullScreenVideoPlayerView(videoURL: processedVideoURL)
                } else if let exportedVideoURL = exportedVideoURL {
                    FullScreenVideoPlayerView(videoURL: exportedVideoURL)
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
            }
            
            ForEach(draggableStickers.indices, id: \.self) { index in
                DraggableStickerView(draggableSticker: $draggableStickers[index], hideButtons: $hideButtons, deleteArea: CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height - 100, width: 100, height: 100), onDelete: {
                    draggableStickers.remove(at: index)
                })
                .frame(width: 100, height: 100)
                .zIndex(draggableStickers[index].zIndex)
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
                            
                            Button(action: {
                                showDrawingOverlay = true
                            }) {
                                Image(systemName: "pencil.and.scribble")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 35, height: 35)
                            
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
                            
                            Button(action: {
                                showDraggableImagePicker = true
                            }) {
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 35, height: 35)
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
                                //                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                //                                    generateImageFromPhoto()
                                //                                }
                                //                            }
                                //                            .font(.title)
                                //                            .padding()
                                //                            .foregroundColor(.white)
                                //                            .cornerRadius(10)
                                //                            .padding(.bottom, 20)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    if let videoFrame = getVideoFrame() {
                                        processVideo(videoFrame: videoFrame)
                                    } else {
                                        print("Video frame could not be determined")
                                    }
                                }
                            }
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                            
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
                    DrawingOverlay(showDrawingOverlay: $showDrawingOverlay) { drawingImage, drawingRect in
                        if let image = drawingImage, let rect = drawingRect {
                            globalIndex += 1
                            
                            let newDraggableDrawing = DraggableDrawing(
                                image: image,
                                position: rect,
                                scale: 1.0,
                                angle: .zero,
                                zIndex: globalIndex
                            )
                            
                            draggableDrawings.append(newDraggableDrawing)
                            selectedDrawingIndex = draggableDrawings.count - 1
                        }
                    }
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
        .sheet(isPresented: $showBackgroundImagePicker) {
            GradientImagePickerView(gradients: gradientOptions, selectedGradient: $selectedGradient, selectedImage: $backgroundImage, showBackgroundImagePicker: $showBackgroundImagePicker)
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
        
        // Overlay görüntüsünü video çerçevesine göre oluştur
        let overlayImage = generateOverlayImage(videoFrame: videoFrame)
        
        let videoProcessor = VideoProcessor(videoURL: videoURL, overlayImage: overlayImage)
        videoProcessor.processVideo { url in
            DispatchQueue.main.async {
                self.processedVideoURL = url
                print(url, "Processed video URL")
                // İşlenmiş videoyu göster
                if let processedURL = url {
                    self.showProcessedVideo(processedURL: processedURL)
                }
            }
        }
    }
    
    private func showProcessedVideo(processedURL: URL) {
        // İşlenmiş videoyu oynatmak için processedVideoURL ayarlanır
        self.processedVideoURL = processedURL
    }
    
    private func generateOverlayImage(videoFrame: CGRect) -> UIImage {
        let size = videoFrame.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        
        
        // Draggable texts
        // Uncomment this block if you want to include draggable texts in the overlay
        // for text in draggableTexts {
        //     let attributes: [NSAttributedString.Key: Any] = [
        //         .font: UIFont(name: text.font.rawValue, size: text.fontSize) ?? UIFont.systemFont(ofSize: text.fontSize),
        //         .foregroundColor: UIColor(text.textColor)
        //     ]
        //     let attributedString = NSAttributedString(string: text.text, attributes: attributes)
        //     let adjustedPosition = CGPoint(
        //         x: text.position.x - videoFrame.origin.x,
        //         y: text.position.y - videoFrame.origin.y
        //     )
        //     attributedString.draw(at: adjustedPosition)
        // }
        
        
        // Draggable images
        for image in draggableImages {
            let adjustedPosition = CGPoint(
                x: image.position.width - videoFrame.origin.x,
                y: image.position.height - videoFrame.origin.y
            )
            let rect = CGRect(origin: adjustedPosition, size: CGSize(width: image.image.size.width , height: image.image.size.height))
            image.image.draw(in: rect)
        }
        
        
        // Draggable stickers
        for sticker in draggableStickers {
            let adjustedPosition = CGPoint(
                x: (sticker.position.width - videoFrame.origin.x) * (size.width / UIScreen.main.bounds.width),
                y: (sticker.position.height - videoFrame.origin.y) * (size.height / UIScreen.main.bounds.height)
            )
            let rect = CGRect(
                origin: adjustedPosition,
                size: CGSize(
                    width: sticker.image.size.width * (size.width / UIScreen.main.bounds.width),
                    height: sticker.image.size.height * (size.height / UIScreen.main.bounds.height)
                )
            )
            sticker.image.draw(in: rect)
        }
        // Draggable drawings
        for drawing in draggableDrawings {
            let adjustedPosition = CGPoint(
                x: drawing.position.origin.x - videoFrame.origin.x,
                y: drawing.position.origin.y - videoFrame.origin.y
            )
            let rect = CGRect(origin: adjustedPosition, size: CGSize(width: drawing.image.size.width , height: drawing.image.size.height))
            drawing.image.draw(in: rect)
            print(drawing.position.size, "drawing.position.size")
        }
        
        
        let composedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return composedImage ?? UIImage()
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
    
    var body: some View {
        VideoPlayerContainer(player: player)
            .onAppear {
                setupPlayer()
                player.play()
            }
            .onDisappear {
                player.pause()
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
            }
            .edgesIgnoringSafeArea(.all)
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
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let playerLayer = AVPlayerLayer(player: player)
        
        
        playerLayer.frame = UIScreen.main.bounds
        controller.view.layer.addSublayer(playerLayer)
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let playerLayer = uiViewController.view.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = UIScreen.main.bounds
        }
    }
}
import UIKit

extension UIView {
    func getTransformedRect() -> CGRect {
        let transformedPath = CGPath(rect: self.bounds, transform: &self.transform)
        let boundingBox = transformedPath.boundingBox
        let adjustedPosition = CGPoint(
            x: self.frame.origin.x + (self.frame.size.width - boundingBox.size.width) / 2,
            y: self.frame.origin.y + (self.frame.size.height - boundingBox.size.height) / 2
        )
        return CGRect(origin: adjustedPosition, size: boundingBox.size)
    }
}

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
    @State private var draggableTimes: [DraggableTime] = []
    @State private var selectedTimeIndex: Int? = nil
    @State private var draggableLocations: [DraggableLocation] = []
    @State private var selectedLocationIndex: Int? = nil
    @State private var selectedTagIndex: Int? = nil
    @State private var showTagOverlay: Bool = false
    @State private var tagText: String = ""
    @State private var draggableTags: [DraggableTag] = []
    @State private var selectedStickerImage: UIImage? = nil
    @State private var globalIndex: CGFloat = 1
    @State private var showDrawingOverlay: Bool = false
    @State private var draggableDrawings: [DraggableDrawing] = []
    @State private var selectedDrawingIndex: Int? = nil
    @State private var backgroundType: BackgroundType = .photo
    //    @State private var exportedVideoURL: URL? = URL(string: "https://videos.pexels.com/video-files/853889/853889-hd_1920_1080_25fps.mp4")
    //    @State private var exportedVideoURL: URL? = URL(string: "https://cdn.pixabay.com/video/2020/06/30/43459-436106182_small.mp4")
    @State private var exportedVideoURL: URL? = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")
    
    
    @State private var showMusicSelectionOverlay: Bool = false
    @State private var selectedSoundURL: URL? = nil
    
    @State private var isMuted: Bool = false
    @State private var  isPlaying: Bool = true
    
    let users = [
        User(username: "Dohn_doe", profileImage: UIImage(systemName: "person.circle.fill")!),
        User(username: "jane_smith", profileImage: UIImage(systemName: "person.circle.fill")!),
        User(username: "alex_jones", profileImage: UIImage(systemName: "person.circle.fill")!),
        User(username: "emily_davis", profileImage: UIImage(systemName: "person.circle.fill")!),
        User(username: "michael", profileImage: UIImage(systemName: "person.circle.fill")!),
        User(username: "omercan", profileImage: UIImage(systemName: "person.circle.fill")!),
        User(username: "salih", profileImage: UIImage(systemName: "person.circle.fill")!),
        User(username: "vita", profileImage: UIImage(systemName: "person.circle.fill")!),
        User(username: "hosna", profileImage: UIImage(systemName: "person.circle.fill")!),
        User(username: "zafer_azar_zafer", profileImage: UIImage(systemName: "person.circle.fill")!),
        User(username: "cemal", profileImage: UIImage(systemName: "person.circle.fill")!),
        User(username: "muzaffer", profileImage: UIImage(systemName: "person.circle.fill")!),
        User(username: "mohammad", profileImage: UIImage(systemName: "person.circle.fill")!),
    ]
    
    
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
                    FullScreenVideoPlayerView(videoURL: processedVideoURL, selectedEffect: $selectedEffect, hideButtons: $hideButtons, isMUted: $isMuted)
                        .edgesIgnoringSafeArea(.all)
                }
                else if let exportedVideoURL = exportedVideoURL {
                    FullScreenVideoPlayerView(videoURL: exportedVideoURL, selectedEffect: $selectedEffect, hideButtons: $hideButtons, isMUted: $isMuted)
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
            
            ForEach(draggableTimes.indices, id: \.self) { index in
                DraggableTimeView(draggableTime: $draggableTimes[index], selectedTimeIndex: $selectedTimeIndex, index: index, hideButtons: $hideButtons)
                    .frame(width: 150, height:draggableTimes[index].currentTimeStyle == .analogClock ? 150: 50)
                
                
                    .aspectRatio(contentMode: .fit)
                    .zIndex(draggableTimes[index].zIndex)
                
            }
            
            ForEach(draggableTags.indices, id: \.self) { index in
                DraggableTagView(draggableTag: $draggableTags[index],
                                 hideButtons: $hideButtons,
                                 selectedTagIndex: $selectedTagIndex
                )
                
                .frame(width: 220, height: 40)
                .zIndex(draggableTags[index].zIndex)
            }
            
            ForEach(draggableLocations.indices, id: \.self) { index in
                DraggableLocationView(
                    draggableLocation: $draggableLocations[index],
                    selectedLocationIndex: $selectedLocationIndex,
                    index: index,
                    hideButtons: $hideButtons
                )
                .frame(width: 140, height: 40)
                .zIndex(draggableLocations[index].zIndex)
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
                    selectedTextIndex: $selectedTextIndex,
                    lastScaleValue: $draggableTexts[index].lastScale
                )
                .zIndex(draggableTexts[index].zIndex)
                .onAppear {
                    print("Text Position: \(draggableTexts[index].position), Text Size: \(draggableTexts[index].fontSize)")
                }
            }
            if !showDrawingOverlay && !hideButtons && !showTagOverlay{
                GeometryReader { geometry in
                    AdditionalButtonsView(addTimeImage: {
                        let newDraggableTime = DraggableTime(image: UIImage(), position: .zero, scale: 1.0, angle: .zero, zIndex: globalIndex)
                        globalIndex += 1
                        draggableTimes.append(newDraggableTime)
                        selectedTimeIndex = draggableTimes.count - 1
                    }, addLocationImage: {
                        let newDraggableLocation = DraggableLocation(image: UIImage(), position: .zero, scale: 1.0, angle: .zero, zIndex: globalIndex)
                        globalIndex += 1
                        draggableLocations.append(newDraggableLocation)
                        selectedLocationIndex = draggableLocations.count - 1
                    }, showTagOverlay: $showTagOverlay, isMuted: $isMuted, selectedSoundURL: $selectedSoundURL, isPlaying: $isPlaying)
                    .frame(width: 100)
                    .position(x: geometry.size.width - 30, y: geometry.size.height / 2)
                }
                .zIndex(100)
            }
            
            if !showDrawingOverlay {
                VStack {
                    if !hideButtons && !showTagOverlay {
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
                                    zIndex: globalIndex, lastScale: 1.0
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
                    
                    if  !hideButtons && !showOverlay && !showTagOverlay {
                        VStack {
                            Spacer()
                            Button("Done") {
                                generateImageFromPhoto()
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                    if let videoFrame = getVideoFrame() {
//                                        processVideo(videoFrame: videoFrame)
//                                    } else {
//                                        print("Video frame could not be determined")
//                                    }
//                                }
                                
                            }
                            .font(.title2)
                            .padding()
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                        }
                    }
                    
                    if hideButtons && !showOverlay && !showTagOverlay{
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
            if showTagOverlay {
                TagOverlayView(showTagOverlay: $showTagOverlay, tagText: $tagText, draggableTags: $draggableTags, globalIndex: $globalIndex, allUsers: self.users)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: showTagOverlay)
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
                    fontSize: $draggableTexts[selectedIndex].fontSize, lastScale: $draggableTexts[selectedIndex].lastScale,
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
        .fullScreenCover(isPresented: $showFullScreenPlayer, onDismiss: {
            isPlaying = true
        }) {
            SimpleVideoPlayerView(videoURL: processedVideoURL!)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    isPlaying = false
                }
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
        let soundURL = selectedSoundURL
        
        for draggableTime in draggableTimes {
            print("DraggableTime Position: \(draggableTime.position)")
        }
        let overlayImage = generateOverlayImage(videoFrame: videoFrame, selectedEffect: selectedEffect)
        
        if let effect = selectedEffect {
            switch effect {
            case .monochrome:
                let videoProcessor = VideoProcessor(videoURL: videoURL, overlayImage: overlayImage, isMuted: isMuted, soundURL: soundURL)
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
                let videoProcessor = VideoProcessor(videoURL: videoURL, overlayImage: overlayImage, isMuted: isMuted, soundURL: soundURL)
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
            let videoProcessor = VideoProcessor(videoURL: videoURL, overlayImage: overlayImage, isMuted: isMuted, soundURL: soundURL)
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
        
        for time in draggableTimes {
            allElements.append((image: time.image, text: nil, rect: time.globalFrame, angle: time.angle.radians, zIndex: time.zIndex))
        }
        
        for location in draggableLocations {
            allElements.append((image: location.image, text: nil, rect: location.globalFrame, angle: location.angle.radians, zIndex: location.zIndex))
        }
        
        for tag in draggableTags {
            let scaledFontSize = 26 * tag.lastScaleValue * tag.scale
            let tagAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: scaledFontSize),
                .foregroundColor: UIColor(tag.textColor)
            ]
            
            let attributedTagText = NSAttributedString(string: tag.text, attributes: tagAttributes)
            let tagSize = attributedTagText.size()
            let tagRect = CGRect(
                origin: CGPoint(x: tag.position.width + screenSize.width / 2 - tagSize.width / 2,
                                y: tag.position.height + screenSize.height / 2 - tagSize.height / 2),
                size: tagSize
            )
            
            context?.saveGState()
            
            context?.translateBy(x: tagRect.midX, y: tagRect.midY)
            context?.rotate(by: tag.angle.radians)
            context?.translateBy(x: -tagRect.midX, y: -tagRect.midY)
            
            context?.setFillColor(UIColor(tag.backgroundColor).withAlphaComponent(0.6).cgColor)
            context?.fill(tagRect.insetBy(dx: -6 * tag.lastScaleValue, dy: -6 * tag.lastScaleValue))
            
            attributedTagText.draw(in: tagRect)
            context?.restoreGState()
        }
        
        for drawing in draggableDrawings {
            allElements.append((image: drawing.image, text: nil, rect: drawing.position, angle: drawing.angle.radians, zIndex: drawing.zIndex))
        }
        for text in draggableTexts {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = .center
            
            let normalFontSize = text.fontSize
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: text.font.toUIFont(size: normalFontSize)!,
                .foregroundColor: UIColor(text.textColor),
                .paragraphStyle: paragraphStyle
            ]
            
            let maxWidth = screenSize.width
            let attributedString = NSAttributedString(string: text.text, attributes: textAttributes)
            let textSize = attributedString.boundingRect(
                with: CGSize(width: maxWidth, height: CGFloat.infinity),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil).size
            
            let scaledWidth = textSize.width
            let scaledHeight = textSize.height
            let scaledX = text.position.width * text.lastScale + screenSize.width / 2 - scaledWidth / 2
            let scaledY = text.position.height * text.lastScale + screenSize.height / 2 - scaledHeight / 2
            
            var rect = CGRect(
                origin: CGPoint(x: scaledX, y: scaledY),
                size: CGSize(width: scaledWidth, height: scaledHeight)
            )
            
            context?.saveGState()
            context?.translateBy(x: rect.midX, y: rect.midY)
            context?.scaleBy(x: text.lastScale, y: text.lastScale)
            context?.rotate(by: text.angle.radians)
            context?.translateBy(x: -rect.midX, y: -rect.midY)
            
            context?.setFillColor(UIColor(text.backgroundColor).withAlphaComponent(text.backgroundOpacity).cgColor)
            context?.fill(rect.insetBy(dx: -10, dy: -5))
            attributedString.draw(in: rect)
            
            context?.restoreGState()
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


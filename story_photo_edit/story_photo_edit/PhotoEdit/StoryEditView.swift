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
    @State private var showBackgroundImagePicker: Bool = false
    @State private var showDraggableImagePicker: Bool = false
    @State private var showTagOverlay: Bool = false
    @State private var showDrawingOverlay: Bool = false
    @State private var showStickerPicker: Bool = false
    @State private var showGeneratedImageView: Bool = false
    @State private var showFullScreenPlayer: Bool = false
    
    @State private var draggableTexts: [DraggableText] = []
    @State private var draggableImages: [DraggableImage] = []
    @State private var draggableStickers: [DraggableSticker] = []
    @State private var draggableTimes: [DraggableTime] = []
    @State private var draggableLocations: [DraggableLocation] = []
    @State private var draggableTags: [DraggableTag] = []
    @State private var draggableDrawings: [DraggableDrawing] = []
    
    @State private var selectedTextIndex: Int? = nil
    @State private var selectedImageIndex: Int? = nil
    @State private var selectedTimeIndex: Int? = nil
    @State private var selectedLocationIndex: Int? = nil
    @State private var selectedTagIndex: Int? = nil
    @State private var selectedDrawingIndex: Int? = nil
    @State private var globalIndex: CGFloat = 1
    
    @State private var selectedDraggableImage: UIImage? = nil
    @State private var selectedStickerImage: UIImage? = nil
    @State private var selectedEffect: EffectType? = nil
    
    @State private var backgroundType: BackgroundType = .video
    @State private var backgroundImage: UIImage? = nil
    @State private var selectedGradient: LinearGradient? = nil
    @State private var exportedVideoURL: URL? = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")
    
    @State private var selectedSoundURL: URL? = nil
    @State private var isMuted: Bool = false
    @State private var  isPlaying: Bool = true
    @State private var  isVideoPlaying: Bool = true

    
    @State private var processedVideoURL: URL? = nil
    @State private var generatedImage: UIImage? = nil
    @State private var tagText: String = ""
    
    //    @State private var exportedVideoURL: URL? = URL(string: "https://videos.pexels.com/video-files/853889/853889-hd_1920_1080_25fps.mp4")
    //    @State private var exportedVideoURL: URL? = URL(string: "https://cdn.pixabay.com/video/2020/06/30/43459-436106182_small.mp4")
    
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
    
    
    let gradientOptions: [LinearGradient] = [
        LinearGradient(gradient: Gradient(colors: [.blue, .blue]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [.green, .yellow]), startPoint: .top, endPoint: .bottom)
    ]
    
    var body: some View {
        ZStack {
            switch backgroundType {
            case .photo:
                if let backgroundImage = backgroundImage {
                    GeometryReader { geometry in
                        Image(uiImage: backgroundImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .edgesIgnoringSafeArea(.all)
                    }
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
                    FullScreenVideoPlayerView(videoURL: processedVideoURL, selectedEffect: $selectedEffect, hideButtons: $hideButtons, isMUted: $isMuted, isPlaying: $isVideoPlaying)
                        .edgesIgnoringSafeArea(.all)
                }
                else if let exportedVideoURL = exportedVideoURL {
                    FullScreenVideoPlayerView(videoURL: exportedVideoURL, selectedEffect: $selectedEffect, hideButtons: $hideButtons, isMUted: $isMuted, isPlaying: $isVideoPlaying)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            
            addDraggableElements()
            if !showDrawingOverlay && !hideButtons && !showTagOverlay{
                GeometryReader { geometry in
                    AdditionalButtonsView(addTimeImage: {
                        let newDraggableTime = DraggableTime(image: UIImage(), position: .zero, scale: 1.0, angle: .zero, zIndex: globalIndex)
                        globalIndex += 1
                        draggableTimes.append(newDraggableTime)
                        selectedTimeIndex = draggableTimes.count - 1
                    }, addLocationImage: {
                        let newDraggableLocation = DraggableLocation(position: .zero, scale: 1.0, angle: .zero, zIndex: globalIndex, locationText: "📍Test city", backgroundColor: .black, textColor: .white)
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
                                selectedTextIndex = nil
                                showOverlay = true
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
                                if self.backgroundType == .photo {
                                    
                                    
                                    if let soundURL = selectedSoundURL {
                                        let videoGenerator = VideoGenerator(
                                            backgroundImage: generateBackgroundImage(),
                                            soundURL: soundURL,
                                            selectedEffect: selectedEffect
                                        )
                                        videoGenerator.generateVideo { url in
                                            DispatchQueue.main.async {
                                                if let processedURL = url {
                                                    print("Video generated successfully: \(processedURL)")
                                                    self.processedVideoURL = processedURL
                                                    
                                                    DispatchQueue.main.async {
                                                        print("Processed video URL confirmed: \(self.processedVideoURL!)")
                                                        isPlaying = false
                                                        self.showFullScreenPlayer = true
                                                    }
                                                } else {
                                                    print("Video generation failed")
                                                }
                                            }
                                        }
                                        
                                    } else {
                                        generateImageFromPhoto()
                                    }
                                } else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        if let videoFrame = getVideoFrame() {
                                            processVideo(videoFrame: videoFrame)
                                        } else {
                                            print("Video frame could not be determined")
                                        }
                                    }
                                }
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
            
            if showOverlay {
                OverlayView(showOverlay: $showOverlay,
                            draggableTexts: $draggableTexts,
                            globalIndex: $globalIndex, selectedTextIndex: $selectedTextIndex)
                .zIndex(100)
            }
        }
        
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showBackgroundImagePicker) {
            GradientImagePickerView(gradients: gradientOptions, selectedGradient: $selectedGradient, selectedImage: $backgroundImage, showBackgroundImagePicker: $showBackgroundImagePicker)
        }
        
        .fullScreenCover(isPresented: Binding(
            get: { self.processedVideoURL != nil && self.showFullScreenPlayer },
            set: { self.showFullScreenPlayer = $0 }
        )) {
            if let url = processedVideoURL {
                
                
                
                SimpleVideoPlayerView(videoURL: url,
                                      tagPositions: draggableTags.map { ($0.globalFrame.origin, draggableTags.firstIndex(of: $0) ?? 0) },
                                      locationPositions: draggableLocations.map { ($0.globalFrame.origin, draggableLocations.firstIndex(of: $0) ?? 0) })
              
                    .onAppear {
                        print("Playing video from URL: \(url)")
                        isVideoPlaying = false
                        isPlaying = false
                    }
            } else {
                Text("Video could not be loaded")
                    .foregroundColor(.red)
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
            GeneratedImageView(
                image: generatedImage,
                tagPositions: draggableTags.map { ($0.globalFrame.origin, draggableTags.firstIndex(of: $0) ?? 0) },
                locationPositions: draggableLocations.map { ($0.globalFrame.origin, draggableLocations.firstIndex(of: $0) ?? 0) }
            )
        }


        
        .onChange(of: showOverlay) { newValue in
            hideButtons = newValue
        }

    }
    
    private func addDraggableElements() -> some View {
        ZStack {
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
            
            ForEach(draggableTimes.indices, id: \.self) { index in
                DraggableTimeView(draggableTime: $draggableTimes[index], selectedTimeIndex: $selectedTimeIndex, index: index, hideButtons: $hideButtons)
                    .frame(width: 160, height: draggableTimes[index].currentTimeStyle == .analogClock ? 160 : 50)
                    .aspectRatio(contentMode: .fit)
                    .zIndex(draggableTimes[index].zIndex)
            }
            
            ForEach(draggableTags.indices, id: \.self) { index in
                DraggableTagView(draggableTag: $draggableTags[index],
                                 hideButtons: $hideButtons,
                                 selectedTagIndex: $selectedTagIndex)
                .frame(width: 220, height: 40)
                .zIndex(draggableTags[index].zIndex)
            }
            
            ForEach(draggableLocations.indices, id: \.self) { index in
                DraggableLocationView(draggableLocation: $draggableLocations[index], selectedLocationIndex: $selectedLocationIndex, index: index, hideButtons: $hideButtons)
                    .frame(width: 140, height: 40)
                    .zIndex(draggableLocations[index].zIndex)
            }
            
            ForEach(draggableStickers.indices, id: \.self) { index in
                DraggableStickerView(draggableSticker: $draggableStickers[index], hideButtons: $hideButtons, deleteArea: CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height - 100, width: 100, height: 100))
                    .frame(width: 100, height: 100)
                    .zIndex(draggableStickers[index].zIndex)
            }
            
            ForEach(draggableTexts.indices, id: \.self) { index in
                DraggableTextView(draggableText: $draggableTexts[index], hideButtons: $hideButtons, showOverlay: $showOverlay, selectedTextIndex: $selectedTextIndex, index: index)
                    .zIndex(draggableTexts[index].zIndex)
            }
        }
    }
    
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
    
    private func generateBackgroundImage(selectedEffect: EffectType? = nil) -> UIImage {
        let rootView = ZStack {
            if backgroundType == .photo {
                if let backgroundImage = backgroundImage {
                    GeometryReader { geometry in
                        Image(uiImage: backgroundImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                        //                                       .edgesIgnoringSafeArea(.all)
                    }
                } else if let selectedGradient = selectedGradient {
                    selectedGradient
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Color.clear.edgesIgnoringSafeArea(.all)
                }
            }
            addDraggableElements()
            
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let generatedImage = renderer.image { context in
            window.layer.render(in: context.cgContext)
            
            if let effect = selectedEffect {
                if case .color(let colorOverlay) = effect {
                    context.cgContext.setFillColor(UIColor(colorOverlay).withAlphaComponent(0.1).cgColor)
                    context.cgContext.fill(window.bounds)
                }
            }
        }
        return generatedImage
    }
    
    private func generateImageFromPhoto() {
        let image = generateBackgroundImage()
        
        generatedImage = image
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
        
        let overlayImage = generateBackgroundImage(selectedEffect: selectedEffect)
        
        let videoProcessor = VideoProcessor(videoURL: videoURL, overlayImage: overlayImage, isMuted: isMuted, soundURL: soundURL, selectedEffect: selectedEffect)
        
        videoProcessor.processVideo { url in
            DispatchQueue.main.async {
                self.processedVideoURL = url
                if let processedURL = url {
                    self.processedVideoURL = processedURL
                    self.showFullScreenPlayer = true
                }
            }
        }
    }
    
    private func generateOverlayImage(videoFrame: CGRect, selectedEffect: EffectType?) -> UIImage {
        let screenSize = UIScreen.main.bounds.size
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.opaque = false
        rendererFormat.scale = UIScreen.main.scale
        
        let renderer = UIGraphicsImageRenderer(size: screenSize, format: rendererFormat)
        
        let composedImage = renderer.image { context in
            let image = generateBackgroundImage()
            let rect = CGRect(x: .zero, y: .zero, width: screenSize.width, height: screenSize.height)
            
            context.cgContext.saveGState()
            context.cgContext.translateBy(x: rect.midX, y: rect.midY)
            context.cgContext.translateBy(x: -rect.midX, y: -rect.midY)
            
            context.cgContext.fill(rect)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 7)
            path.addClip()
            image.draw(in: rect)
            context.cgContext.restoreGState()
            
            if let selectedEffect = selectedEffect {
                if case .color(let colorOverlay) = selectedEffect {
                    context.cgContext.setFillColor(UIColor(colorOverlay).withAlphaComponent(0.1).cgColor)
                    context.cgContext.fill(CGRect(origin: .zero, size: screenSize))
                }
            }
        }
        return composedImage
    }
}

struct GeneratedImageView: View {
    var image: UIImage?
    var tagPositions: [(position: CGPoint, index: Int)]
    var locationPositions: [(position: CGPoint, index: Int)]
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("No image generated")
            }

        }
        .onAppear {
            print(tagPositions, locationPositions, "positions")
        }
    }
}

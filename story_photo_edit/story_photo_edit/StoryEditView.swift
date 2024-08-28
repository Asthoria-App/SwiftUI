//
//  StoryEditView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 19.08.2024.
//

import SwiftUI
import UIKit
enum DraggableType {
    case text, image, sticker
}



struct StoryEditView: View {
    @State private var showTextEditor: Bool = false
    @State private var userText: String = ""
    @State private var textPosition: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var angle: Angle = .zero
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
    @State private var imagePosition: CGSize = .zero
    @State private var imageScale: CGFloat = 1.0
    @State private var imageAngle: Angle = .zero
    @State private var imageShowDeleteButton: Bool = false
    @State private var selectedGradient: LinearGradient? = nil
    @State private var textBackgroundColor: Color = .clear
    @State private var originalTextColor: Color = .clear
    @State private var generatedImage: UIImage? = nil
    @State private var showGeneratedImageView: Bool = false
    @State private var buttonsHidden: Bool = false
    @State private var showEyedropper: Bool = false
    @State private var fontSize: CGFloat = 34
    @State private var eyedropperPosition: CGSize = .zero
    @State private var selectedColor: Color = .white
    @State private var draggableTexts: [DraggableText] = []
    @State private var selectedTextIndex: Int? = nil
    @State private var draggableImages: [DraggableImage] = []
    @State private var selectedImageIndex: Int? = nil
    
    @State private var showStickerPicker: Bool = false
    @State private var draggableStickers: [DraggableSticker] = []
    @State private var selectedStickerImage: UIImage? = nil
    
    @State private var drawingImages: [UIImage] = []
    @State private var globalIndex: CGFloat = 1

    @State private var showDrawingOverlay: Bool = false

    let gradientOptions: [LinearGradient] = [
        LinearGradient(gradient: Gradient(colors: [.blue, .blue]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [.green, .yellow]), startPoint: .top, endPoint: .bottom)
    ]
   

    


    
    var body: some View {
        ZStack {
            if let backgroundImage = backgroundImage {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false)

            } else if let selectedGradient = selectedGradient {
                selectedGradient
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false)

            } else {
                
                Image("image")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false)

            }
            
                ForEach(drawingImages, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                                         .aspectRatio(contentMode: .fit)
                                         .frame(maxWidth: .infinity, maxHeight: .infinity)

                                         .edgesIgnoringSafeArea(.all)
                                         .allowsHitTesting(false)
                }
       
            ForEach(draggableImages.indices, id: \.self) { index in
                DraggableImageView(draggableImage: $draggableImages[index], selectedImageIndex: $selectedImageIndex, index: index, hideButtons: $hideButtons)
                    .frame(width: 200, height: 200)
                    .padding(.horizontal, 50)
                    .aspectRatio(contentMode: .fill)
                    .zIndex(draggableImages[index].zIndex) // Burada zIndex'i öğeye bağlıyoruz
            }

            ForEach(draggableStickers.indices, id: \.self) { index in
                DraggableStickerView(draggableSticker: $draggableStickers[index], hideButtons: $hideButtons, deleteArea: CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height - 100, width: 200, height: 200), onDelete: {
                    draggableStickers.remove(at: index)
                })
                .frame(width: 200, height: 200)
                .zIndex(draggableStickers[index].zIndex) // Burada zIndex'i öğeye bağlıyoruz
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
                .zIndex(draggableTexts[index].zIndex) // Burada zIndex'i öğeye bağlıyoruz
            }
            
            if showEyedropper {
                DraggableDropView(position: $eyedropperPosition, color: $textColor, onDragEnd: {
                    showEyedropper = false
                    showOverlay = true
                }, onColorChange: { newColor in
                    if let selectedIndex = selectedTextIndex {
                        draggableTexts[selectedIndex].textColor = newColor
                    }
                })
            }
            
            if !showEyedropper && !showDrawingOverlay {
                VStack {
                    if !buttonsHidden && !hideButtons {
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
                                    zIndex: globalIndex                                )
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
                    
                    if hideButtons && !showOverlay {
                        VStack {
                            Spacer()
                            Image(systemName: "trash.fill")
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(50)
                                .frame(width: 100, height: 100)
                        }
                        .frame(height: 150)
                    }
                    
                    if !buttonsHidden && !hideButtons && !showOverlay {
                        VStack {
                            Spacer()
                            Button("Done") {
                                buttonsHidden = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    generateImage()
                                }
                            }
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                        }
                    }
                }
                .zIndex(100)
            }

            if showDrawingOverlay {
                DrawingOverlay(showDrawingOverlay: $showDrawingOverlay) { drawingImage in
                    if let image = drawingImage {
                        globalIndex += 1
                        drawingImages.append(image)
                    }
                }
                .transition(.opacity)
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
                    showEyedropper: $showEyedropper,
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
                        let newImage = DraggableImage(image: selectedImage, position: .zero, scale: 1.0, angle: .zero, zIndex: globalIndex )
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
    
    func generateImage() {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let renderer = UIGraphicsImageRenderer(bounds: window!.bounds)
        generatedImage = renderer.image { context in
            window?.layer.render(in: context.cgContext)
            
        }

        buttonsHidden = false
        showGeneratedImageView = true
    }

        func mergeImages(background: UIImage?, overlay: [UIImage]) -> UIImage? {
            guard let background = background else { return nil }
            
            let size = background.size
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            
            background.draw(in: CGRect(origin: .zero, size: size))
            
            for image in overlay {
                image.draw(in: CGRect(origin: .zero, size: size))
            }
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
        }
}

struct DraggableSticker {
    var image: UIImage
    var position: CGSize
    var scale: CGFloat
    var angle: Angle
    var zIndex: CGFloat

}

struct DraggableStickerView: View {
    @Binding var draggableSticker: DraggableSticker
    @Binding var hideButtons: Bool
    let deleteArea: CGRect
    var onDelete: () -> Void

    @State private var isDraggingOverDelete: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var shouldRemove: Bool = false
    @State private var lastScaleValue: CGFloat = 1.0

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    if !shouldRemove {
                        Image(uiImage: draggableSticker.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .scaleEffect(lastScaleValue * draggableSticker.scale) // Apply the last scale value
                            .rotationEffect(draggableSticker.angle)
                            .position(x: geometry.size.width / 2 + draggableSticker.position.width + dragOffset.width,
                                      y: geometry.size.height / 2 + draggableSticker.position.height + dragOffset.height)
                            .gesture(
                                SimultaneousGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            hideButtons = true
                                            dragOffset = value.translation
                                            
                                            let deleteAreaFrame = CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height - 100, width: 200, height: 200)
                                            if deleteAreaFrame.contains(CGPoint(x: value.location.x + geometry.frame(in: .global).minX, y: value.location.y + geometry.frame(in: .global).minY)) {
                                                isDraggingOverDelete = true
                                            } else {
                                                isDraggingOverDelete = false
                                            }
                                        }
                                        .onEnded { value in
                                            if isDraggingOverDelete {
                                                withAnimation(.smooth(duration: 0.7)) {
                                                    shouldRemove = true
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                                    onDelete()
                                                }
                                            } else {
                                                draggableSticker.position.width += dragOffset.width
                                                draggableSticker.position.height += dragOffset.height
                                            }
                                            dragOffset = .zero
                                            hideButtons = false
                                            isDraggingOverDelete = false
                                        },
                                    RotationGesture()
                                        .onChanged { newAngle in
                                            draggableSticker.angle += newAngle - draggableSticker.angle
                                        }
                                        .onEnded { newAngle in
                                            draggableSticker.angle = newAngle
                                        }
                                )
                                .simultaneously(with: MagnificationGesture()
                                    .onChanged { value in
                                        draggableSticker.scale = value
                                    }
                                    .onEnded { _ in
                                        lastScaleValue *= draggableSticker.scale // Store the final scale value
                                        draggableSticker.scale = 1.0
                                    }
                                )
                            )
                    }
                }
            }
        }
    }
}



struct DraggableText {
    var text: String
    var position: CGSize
    var scale: CGFloat
    var angle: Angle
    var textColor: Color
    var backgroundColor: Color
    var backgroundOpacity: CGFloat
    var font: CustomFont
    var fontSize: CGFloat
    var originalTextColor: Color
    var zIndex: CGFloat
    
    init(text: String, position: CGSize, scale: CGFloat, angle: Angle, textColor: Color, backgroundColor: Color, backgroundOpacity: CGFloat, font: CustomFont, fontSize: CGFloat, zIndex: CGFloat) {
        self.text = text
        self.position = position
        self.scale = scale
        self.angle = angle
        self.textColor = textColor
        self.originalTextColor = textColor
        self.backgroundColor = backgroundColor
        self.backgroundOpacity = backgroundOpacity
        self.font = font
        self.fontSize = fontSize
        self.zIndex = zIndex
    }
}


import Combine

struct BottomSheetStickerPickerView: View {
    @Binding var selectedStickerImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    let stickers: [String] = ["1", "2", "3", "4", "5", "7", "8", "1", "4", "2", "4", "3"]
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    @State private var searchText: String = ""
    @State private var filteredStickers: [String] = []
    @State private var searchCancellable: AnyCancellable?
    
    var body: some View {
        ZStack {
            BlurBackground()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Select a Sticker")
                    .font(.headline)
                    .padding()
                
                TextField("Search stickers", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchText) { newValue in
                        filterStickers(with: newValue)
                    }

                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        if filteredStickers.isEmpty {
                            Text("No stickers found")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(filteredStickers.indices, id: \.self) { index in
                                let stickerName = filteredStickers[index]
                                
                                if let stickerImage = UIImage(named: stickerName) {
                                    Image(uiImage: stickerImage)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .background(Color.clear)
                                        .onTapGesture {
                                            selectedStickerImage = stickerImage
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .padding()
            .background(Color.black)
            .cornerRadius(10)
            .shadow(radius: 5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .onAppear {
                filterStickers(with: searchText)
                print("Initial filtering done with text: \(searchText)")
            }
        }
    }
    private func filterStickers(with text: String) {
        if text.isEmpty {
            filteredStickers = stickers
        } else {
            filteredStickers = stickers.filter { $0.contains(text) }
        }
        print("Filtered stickers: \(filteredStickers)")
    }

}



struct BlurBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
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

struct GradientImagePickerView: View {
    let gradients: [LinearGradient]
    @Binding var selectedGradient: LinearGradient?
    @Binding var selectedImage: UIImage?
    @Binding var showBackgroundImagePicker: Bool
    
    @State private var showPhotoPicker = false
    
    var body: some View {
        VStack {
            Text("Choose a Background")
                .font(.headline)
                .padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(gradients.indices, id: \.self) { index in
                        Button(action: {
                            selectedGradient = gradients[index]
                            selectedImage = nil
                            showBackgroundImagePicker = false
                        }) {
                            gradients[index]
                                .frame(width: 100, height: 100)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                    }
                }
                .padding()
            }
            
            Button("Choose from Gallery") {
                showPhotoPicker = true
            }
            .padding()
            .sheet(isPresented: $showPhotoPicker) {
                ImagePicker(selectedImage: $selectedImage)
                    .onDisappear {
                        showBackgroundImagePicker = false
                    }
            }
            
            Button("Cancel") {
                showBackgroundImagePicker = false
            }
            .padding()
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                picker.dismiss(animated: true)
            }
        }
    }
}

struct DraggableImageView: View {
    @Binding var draggableImage: DraggableImage
    @Binding var selectedImageIndex: Int?
    var index: Int
    @Binding var hideButtons: Bool
    
    @State private var isDraggingOverDelete: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var shouldRemove: Bool = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    if !shouldRemove {
                        Image(uiImage: draggableImage.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .cornerRadius(12)
                            .clipped()
                            .scaleEffect(draggableImage.lastScaleValue * draggableImage.scale)
                            .rotationEffect(draggableImage.angle)
                            .position(x: geometry.size.width / 2 + draggableImage.position.width + dragOffset.width,
                                      y: geometry.size.height / 2 + draggableImage.position.height + dragOffset.height)
                            .gesture(
                                SimultaneousGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            hideButtons = true
                                            dragOffset = value.translation
                                            
                                            let deleteAreaFrame = CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height - 100, width: 200, height: 200)
                                            if deleteAreaFrame.contains(CGPoint(x: value.location.x + geometry.frame(in: .global).minX, y: value.location.y + geometry.frame(in: .global).minY)) {
                                                isDraggingOverDelete = true
                                            } else {
                                                isDraggingOverDelete = false
                                            }
                                        }
                                        .onEnded { value in
                                            if isDraggingOverDelete {
                                                withAnimation(.smooth(duration: 0.7)) {
                                                    shouldRemove = true
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                                    draggableImage = DraggableImage(image: UIImage(), position: draggableImage.position, scale: 1.0, angle: .zero, zIndex: CGFloat(selectedImageIndex!))
                                                }
                                            } else {
                                                draggableImage.position.width += dragOffset.width
                                                draggableImage.position.height += dragOffset.height
                                            }
                                            dragOffset = .zero
                                            hideButtons = false
                                            isDraggingOverDelete = false
                                        },
                                    RotationGesture()
                                        .onChanged { newAngle in
                                            draggableImage.angle += newAngle - draggableImage.angle
                                        }
                                        .onEnded { newAngle in
                                            draggableImage.angle = newAngle
                                        }
                                )
                                .simultaneously(with: MagnificationGesture()
                                    .onChanged { value in
                                        draggableImage.scale = value
                                    }
                                    .onEnded { _ in
                                        draggableImage.lastScaleValue *= draggableImage.scale
                                        draggableImage.scale = 1.0
                                    }
                                )
                            )
                            .onTapGesture {
                                selectedImageIndex = index
                            }
                    }
                }
            }
        }
    }
}

struct DraggableTextView: View {
    @Binding var userText: String
    @Binding var textPosition: CGSize
    @Binding var scale: CGFloat
    @Binding var angle: Angle
    @Binding var showDeleteButton: Bool
    @Binding var hideButtons: Bool
    @Binding var showOverlay: Bool
    @Binding var textColor: Color
    @Binding var backgroundColor: Color
    @Binding var backgroundOpacity: CGFloat
    @Binding var selectedFont: CustomFont
    @Binding var fontSize: CGFloat
    var index: Int
    @Binding var selectedTextIndex: Int?
    
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var currentDragOffset: CGSize = .zero
    @State private var isDraggingOverDelete: Bool = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Text(userText)
                    .font(selectedFont.toSwiftUIFont(size: fontSize))
                    .foregroundColor(textColor)
                    .padding(8)
                    .background(backgroundColor.opacity(backgroundOpacity))
                    .cornerRadius(5)
                    .position(positionInBounds(geometry))
                    .scaleEffect(lastScaleValue * scale)
                    .rotationEffect(angle)
                    .gesture(
                        SimultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    hideButtons = true
                                    let translation = value.translation
                                    let inverseTranslation = rotatePoint(point: translation, aroundOriginBy: -angle)
                                    textPosition = CGSize(
                                        width: currentDragOffset.width + inverseTranslation.width / lastScaleValue,
                                        height: currentDragOffset.height + inverseTranslation.height / lastScaleValue
                                    )
                                    
                                    let deleteAreaFrame = CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height - 100, width: 200, height: 200)
                                    if deleteAreaFrame.contains(CGPoint(x: value.location.x, y: value.location.y)) {
                                        isDraggingOverDelete = true
                                    } else {
                                        isDraggingOverDelete = false
                                    }
                                }
                                .onEnded { value in
                                    if isDraggingOverDelete {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation(.smooth(duration: 0.7)) {
                                                scale = 0.4
                                            }
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            userText = ""
                                            textColor = .white
                                            textPosition = .zero
                                            backgroundOpacity = 0
                                            scale = 1.0
                                        }
                                    } else {
                                        print("Text not dropped on delete button!")
                                    }
                                    isDraggingOverDelete = false
                                    hideButtons = false
                                    currentDragOffset = textPosition
                                },
                            RotationGesture()
                                .onChanged { newAngle in
                                    angle += newAngle - angle
                                }
                                .onEnded { newAngle in
                                    angle = newAngle
                                }
                        )
                        .simultaneously(with: MagnificationGesture()
                            .onChanged { value in
                                scale = value
                            }
                            .onEnded { _ in
                                lastScaleValue *= scale
                                scale = 1.0
                            }
                        )
                    )
                    .onTapGesture {
                        hideButtons = false
                        showOverlay = true
                        selectedTextIndex = index
                    }
                    .onLongPressGesture {
                        showDeleteButton = true
                    }
            }
        }
    }
    
    private func rotatePoint(point: CGSize, aroundOriginBy angle: Angle) -> CGSize {
        let radians = CGFloat(angle.radians)
        let newX = point.width * cos(radians) - point.height * sin(radians)
        let newY = point.width * sin(radians) + point.height * cos(radians)
        return CGSize(width: newX, height: newY)
    }
    
    private func positionInBounds(_ geometry: GeometryProxy) -> CGPoint {
        let x = geometry.size.width / 2 + textPosition.width
        let y = geometry.size.height / 2 + textPosition.height
        return CGPoint(x: x, y: y)
    }
}


struct OverlayView: View {
    @Binding var showOverlay: Bool
    @Binding var userText: String
    @Binding var textColor: Color
    @Binding var backgroundColor: Color
    @Binding var backgroundOpacity: CGFloat
    @Binding var selectedFont: CustomFont
    @Binding var originalTextColor: Color
    @Binding var fontSize: CGFloat
    @Binding var showEyedropper: Bool
    var onChange: () -> Void
    
    @State private var textHeight: CGFloat = 30
    @State private var textWidth: CGFloat = 30
    
    @State private var showFontCollection: Bool = false
    @State private var showColorCollection: Bool = true
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissKeyboard()
                    showOverlay = false
                }
            
            VStack {
                HStack {
                    VStack {
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .frame(width: 60, height: 240)
                                .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                                    let percentage = min(max(0, 1 - value.location.y / 200), 1)
                                    fontSize = percentage * 70 + 10
                                })
                            
                            Capsule()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.8)]), startPoint: .bottom, endPoint: .top))
                                .frame(width: 10, height: 200 * CGFloat(fontSize / 80))
                                .offset(x: 0)
                            
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 10, height: 200)
                                .offset(x: 0)
                                .mask(Rectangle().frame(height: 200))
                        }
                        .padding(.top, -280)
                        .offset(y: 300)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showFontCollection = false
                            showColorCollection = true
                        }
                    }) {
                        Image(systemName: "paintpalette.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(8)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        withAnimation {
                            showFontCollection = true
                            showColorCollection = false
                        }
                    }) {
                        Image(systemName: "a.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(5)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        withAnimation {
                            
                            if textColor == .white && backgroundOpacity == 0.0 {
                                backgroundColor = .black
                                backgroundOpacity = 0.7
                                
                            } else if backgroundColor == .black && backgroundOpacity == 0.7 && textColor == .white {
                                backgroundColor = .white
                                textColor = .black
                                backgroundOpacity = 0.7
                                
                            } else if  backgroundColor == .white && textColor == .black && backgroundOpacity == 0.7 {
                                textColor = .white
                                backgroundOpacity = 0.0
                                
                            } else if backgroundOpacity == 0.0 {
                                backgroundOpacity = 0.7
                                backgroundColor = .white
                            } else if backgroundOpacity == 0.7
                                        
                                        && backgroundColor == .white {
                                backgroundColor = textColor
                                textColor = .white
                            } else {
                                
                                textColor = originalTextColor
                                backgroundOpacity = 0.0
                            }
                        }
                    }) {
                        Image(systemName: "square.text.square.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(5)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        dismissKeyboard()
                        showOverlay = false
                    }) {
                        Text("Done")
                            .font(Font.system(size: 21, weight: .medium))
                            .padding(7)
                            .foregroundColor(.white)
                    }
                }
                .padding(.top)
                .padding(.trailing)
                .frame(maxWidth: .infinity)
                .background(Color.clear)
                
                Spacer()
                
                DynamicHeightTextView(
                    text: $userText,
                    minHeight: 30,
                    maxHeight: 150,
                    textHeight: $textHeight,
                    textColor: $textColor,
                    backgroundOpacity: $backgroundOpacity,
                    backgroundColor: $backgroundColor,
                    selectedFont: $selectedFont,
                    textWidth: $textWidth,
                    fontSize: $fontSize
                )
                .frame(width: textWidth, height: textHeight)
                .padding(8)
                .background(Color.clear)
                .cornerRadius(5)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        focusTextView()
                    }
                }
                
                ZStack {
                    if showColorCollection {
                        ColorSelectionView(selectedColor: $textColor, originalColor: $originalTextColor, showEyedropper: $showEyedropper, showOverlay: $showOverlay)
                            .padding(.horizontal)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.0))
                            .cornerRadius(10)
                            .padding(.bottom, 5)
                            .transition(.opacity)
                    }
                    
                    if showFontCollection {
                        FontCollectionView(selectedFont: $selectedFont)
                            .padding(.horizontal)
                            .frame(height: 35)
                            .background(Color.white.opacity(0.0))
                            .cornerRadius(10)
                            .padding(.bottom, 5)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: showColorCollection || showFontCollection)
            }
            .padding(.top, 0)
        }
    }
}


struct DynamicHeightTextView: UIViewRepresentable {
    @Binding var text: String
    var minHeight: CGFloat
    var maxHeight: CGFloat
    @Binding var textHeight: CGFloat
    @Binding var textColor: Color
    @Binding var backgroundOpacity: CGFloat
    @Binding var backgroundColor: Color
    @Binding var selectedFont: CustomFont
    @Binding var textWidth: CGFloat
    @Binding var fontSize: CGFloat
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: DynamicHeightTextView
        
        init(_ parent: DynamicHeightTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            let maxWidth = UIScreen.main.bounds.width * 0.9
            let size = textView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
            self.parent.textHeight = max(self.parent.minHeight, min(size.height, self.parent.maxHeight))
            self.parent.text = textView.text
            DispatchQueue.main.async {
                self.parent.textWidth = min(size.width, maxWidth)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.delegate = context.coordinator
        textView.text = text
        textView.backgroundColor = UIColor(backgroundColor).withAlphaComponent(backgroundOpacity)
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 5
        textView.textColor = UIColor(textColor)
        textView.becomeFirstResponder()
        
        if let uiFont = selectedFont.toUIFont(size: fontSize) {
            textView.font = uiFont
        } else {
            textView.font = UIFont.systemFont(ofSize: fontSize)
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.textColor = UIColor(textColor)
        uiView.backgroundColor = UIColor(backgroundColor).withAlphaComponent(backgroundOpacity)
        
        if let uiFont = selectedFont.toUIFont(size: fontSize) {
            uiView.font = uiFont
        }
        
        let maxWidth = UIScreen.main.bounds.width * 0.9
        let size = uiView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        DispatchQueue.main.async {
            self.textHeight = max(self.minHeight, min(size.height, self.maxHeight))
            self.textWidth = min(size.width, maxWidth)
        }
    }
}

struct ColorSelectionView: View {
    @Binding var selectedColor: Color
    @Binding var originalColor: Color
    @Binding var showEyedropper: Bool
    @Binding var showOverlay: Bool

    var onColorSelected: ((Color) -> Void)? = nil

    let colors: [Color] = [
        .red, .green, .blue, .yellow, .orange, .purple,
        .pink, .cyan, .mint, .teal, .indigo, .brown,
        .gray, .black, .white
    ]

    var body: some View {
        HStack {
            Button(action: {
                showEyedropper.toggle()
                showOverlay = false
            }) {
                ZStack {
                    Circle()
                        .fill(selectedColor == .white ? Color.black : selectedColor)
                        .frame(width: 35, height: 35)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 0)

                    Image(systemName: "eyedropper")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 35, height: 35)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(colors, id: \.self) { color in
                        ZStack {
                            Circle()
                                .fill(color)
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            color == selectedColor ? Color.white : Color.white.opacity(0.5),
                                            lineWidth: color == selectedColor ? 3 : 1.5
                                        )
                                )
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
                        }
                        .onTapGesture {
                            withAnimation {
                                selectedColor = color
                                originalColor = color
                                onColorSelected?(color)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
    }
}

struct FontCollectionView: View {
    @Binding var selectedFont: CustomFont
    
    let fonts: [CustomFont] = [
        .roboto,
        .greyQo,
        .greatVibes,
        .righteous
        
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(fonts, id: \.self) { font in
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 35, height: 35)
                        
                        Text("Aa")
                            .font(font.toSwiftUIFont(size: 24))
                            .foregroundColor(.white)
                            .padding(2)
                    }
                    .onTapGesture {
                        selectedFont = font
                    }
                }
            }
            .padding()
        }
    }
}

func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

func focusTextView() {
    UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
}


struct EyedropperView: View {
    @Binding var showEyedropper: Bool
    @Binding var textColor: Color
    @Binding var position: CGSize
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let dropPosition = CGPoint(x: value.location.x, y: value.location.y)
                        let newColor = getColor(at: dropPosition)
                        textColor = newColor
                        position = value.translation
                    }
                    .onEnded { _ in
                        showEyedropper = false
                    }
            )
    }
}

import UIKit
import SwiftUI
func getColor(at point: CGPoint) -> Color {
    let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
    
    guard let window = keyWindow else { return Color.white }
    
    let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
    let image = renderer.image { context in
        window.layer.render(in: context.cgContext)
    }
    
    guard let pixelColor = image.getPixelColor(at: point) else {
        return Color.white
    }
    
    return Color(pixelColor)
}

import UIKit

extension UIImage {
    func getPixelColor(at point: CGPoint) -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = self.size.width
        let height = self.size.height
        
        guard point.x >= 0 && point.x < width &&
                point.y >= 0 && point.y < height else { return nil }
        
        let pixelData = UnsafeMutablePointer<UInt8>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let context = CGContext(
            data: pixelData,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        )
        
        context?.translateBy(x: -point.x, y: -(self.size.height - point.y))
        context?.draw(cgImage, in: CGRect(origin: .zero, size: self.size))
        
        let r = CGFloat(pixelData[0]) / 255.0
        let g = CGFloat(pixelData[1]) / 255.0
        let b = CGFloat(pixelData[2]) / 255.0
        let a = CGFloat(pixelData[3]) / 255.0
        
        pixelData.deallocate()
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
struct DraggableDropView: View {
    @Binding var position: CGSize
    @Binding var color: Color
    var onDragEnd: () -> Void
    var onColorChange: (Color) -> Void
    
    @State private var lastDragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 15, height: 15)
                .offset(y: 40)
            
            Image(systemName: "drop.fill")
                .resizable()
                .frame(width: 50, height: 60)
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 180))
        }
        .position(x: position.width, y: position.height)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    position = CGSize(
                        width: lastDragOffset.width + value.translation.width,
                        height: lastDragOffset.height + value.translation.height
                    )
                    
                    let colorSamplePoint = CGPoint(x: position.width, y: position.height - 30)
                    color = getColor(at: colorSamplePoint)
                    
                    onColorChange(color)
                }
                .onEnded { _ in
                    lastDragOffset = position
                    onDragEnd()
                }
        )
        .onAppear {
            position = CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 2)
            lastDragOffset = position
        }
    }
}
struct DraggableImage {
    var image: UIImage
    var position: CGSize
    var scale: CGFloat
    var angle: Angle
    var lastScaleValue: CGFloat = 1.0
    var zIndex: CGFloat

}

import SwiftUI
import PencilKit

struct DrawingView: UIViewRepresentable {
    @Binding var tool: PKTool
    @Binding var canvasView: PKCanvasView
    @Binding var drawings: [PKDrawing]

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = tool
        canvasView.drawingPolicy = .anyInput
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.delegate = context.coordinator
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = tool
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingView
        var lastDrawing: PKDrawing?

        init(_ parent: DrawingView) {
            self.parent = parent
        }

        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
            lastDrawing = canvasView.drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            guard let lastDrawing = lastDrawing else { return }
            let newStrokes = canvasView.drawing.strokes.filter { newStroke in
                !lastDrawing.strokes.contains(where: { areStrokesEqual($0, newStroke) })
            }
            if !newStrokes.isEmpty {
                let newDrawing = PKDrawing(strokes: newStrokes)
                parent.drawings.append(newDrawing)
            }
            self.lastDrawing = canvasView.drawing
        }

        private func areStrokesEqual(_ stroke1: PKStroke, _ stroke2: PKStroke) -> Bool {
            guard stroke1.path.count == stroke2.path.count else {
                return false
            }

            for i in 0..<stroke1.path.count {
                let point1 = stroke1.path[i]
                let point2 = stroke2.path[i]
                if !arePointsEqual(point1, point2) {
                    return false
                }
            }

            return true
        }

        private func arePointsEqual(_ point1: PKStrokePoint, _ point2: PKStrokePoint) -> Bool {
            return point1.location == point2.location &&
                point1.timeOffset == point2.timeOffset &&
                point1.size == point2.size &&
                point1.opacity == point2.opacity &&
                point1.force == point2.force &&
                point1.azimuth == point2.azimuth &&
                point1.altitude == point2.altitude
        }
    }
}

struct DrawingOverlay: View {
    @Binding var showDrawingOverlay: Bool
    @State private var tool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    @State private var selectedTool: ToolType = .pen
    @State private var lineWidth: CGFloat = 5
    @State private var toolColor: Color = .black
    @State private var eyedropperPosition: CGSize = .zero
    @State private var showEyedropper: Bool = false
    var onComplete: (UIImage?) -> Void
    @State private var canvasView = PKCanvasView()
    @State private var drawings: [PKDrawing] = []
    @State private var isDraggingEyedropper = false

    enum ToolType {
        case pen, crayon, marker, watercolor, eraser
    }

    var body: some View {
        ZStack {
            DrawingView(tool: $tool, canvasView: $canvasView, drawings: $drawings)
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(!isDraggingEyedropper)

            VStack {
                HStack {
                    Button("Back") {
                        undoLastDrawing()
                    }
                    .foregroundColor(.white)
                    
                    ToolButton(
                        iconName: "pencil.tip.crop.circle",
                        isSelected: selectedTool == .pen
                    ) {
                        selectedTool = .pen
                        updateTool()
                    }

                    ToolButton(
                        iconName: "pencil.tip.crop.circle.badge.plus",
                        isSelected: selectedTool == .crayon
                    ) {
                        selectedTool = .crayon
                        updateTool()
                    }

                    ToolButton(
                        iconName: "highlighter",
                        isSelected: selectedTool == .marker
                    ) {
                        selectedTool = .marker
                        updateTool()
                    }

                    ToolButton(
                        iconName: "paintbrush.pointed.fill",
                        isSelected: selectedTool == .watercolor
                    ) {
                        selectedTool = .watercolor
                        updateTool()
                    }

                    ToolButton(
                        iconName: "eraser.fill",
                        isSelected: selectedTool == .eraser
                    ) {
                        selectedTool = .eraser
                        tool = PKEraserTool(.bitmap)
                    }

                    Spacer()

                    Button("Done") {
                        let drawingImage = captureDrawing(from: canvasView)
                        showDrawingOverlay = false
                        onComplete(drawingImage)
                    }
                    .foregroundColor(.white)
                }
                .padding()

                Spacer()

                if !showEyedropper {
                    ColorSelectionView(
                        selectedColor: $toolColor,
                        originalColor: $toolColor,
                        showEyedropper: $showEyedropper, showOverlay: .constant(false),
                        onColorSelected: { color in
                            toolColor = color
                            updateTool()
                        }
                    )
                    .padding(.horizontal)
                    .frame(height: 50)
                    .background(Color.white.opacity(0.0))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                }
            }

            if showEyedropper {
                DraggableDropView(position: $eyedropperPosition, color: $toolColor, onDragEnd: {
                    showEyedropper = false
                    updateTool()
                    isDraggingEyedropper = false
                }, onColorChange: { newColor in
                    toolColor = newColor
                    updateTool()
                })
                .zIndex(100)
                .gesture(DragGesture()
                    .onChanged { _ in
                        isDraggingEyedropper = true
                    }
                )
            }

            VStack {
                Spacer()
                VerticalSlider(value: $lineWidth, range: 5...35)
                    .onChange(of: lineWidth) { newValue in
                        updateTool()
                    }
                Spacer()
            }
            .padding(.leading, 6)
            .padding(.bottom, 200)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            // Frame rate sınırlandırmasını kaldır
            canvasView.isMultipleTouchEnabled = false
            canvasView.isUserInteractionEnabled = true
        }
    }

    private func updateTool() {
        switch selectedTool {
        case .pen:
            tool = PKInkingTool(.pen, color: UIColor(toolColor), width: lineWidth)
        case .crayon:
            tool = PKInkingTool(.crayon, color: UIColor(toolColor), width: lineWidth)
        case .marker:
            tool = PKInkingTool(.marker, color: UIColor(toolColor), width: lineWidth)
        case .watercolor:
            tool = PKInkingTool(.watercolor, color: UIColor(toolColor), width: lineWidth)
        case .eraser:
            tool = PKEraserTool(.bitmap)
        }
    }

    private func undoLastDrawing() {
        if !drawings.isEmpty {
            drawings.removeLast()
            let combinedDrawing = drawings.reduce(PKDrawing()) { partialResult, drawing in
                var result = partialResult
                result.strokes.append(contentsOf: drawing.strokes)
                return result
            }
            canvasView.drawing = combinedDrawing
        }
    }
}

struct ToolButton: View {
    var iconName: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 25, height: 25)
                .padding(2)
                .background(isSelected ? Color.white : Color.clear)
                .foregroundColor(isSelected ? Color.black : Color.white)
                .clipShape(Circle())
        }
        .padding(3)
    }
}


struct VerticalSlider: View {
    @Binding var value: CGFloat
    var range: ClosedRange<CGFloat>
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .frame(width: 60, height: 240)
                .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                    let percentage = min(max(0, 1 - value.location.y / 200), 1)
                    self.value = percentage * (range.upperBound - range.lowerBound) + range.lowerBound
                })
            
            Capsule()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.8)]), startPoint: .bottom, endPoint: .top))
                .frame(width: 10, height: 200 * CGFloat(value / range.upperBound))
                .offset(x: 0)
            
            Capsule()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 10, height: 200)
                .offset(x: 0)
                .mask(Rectangle().frame(height: 200))
        }
        .padding(.top, -280)
        .offset(y: 300)
    }
}
func captureDrawing(from view: PKCanvasView) -> UIImage? {
    let drawingRect = view.bounds
    let renderer = UIGraphicsImageRenderer(size: drawingRect.size)
    return renderer.image { context in
        view.drawing.image(from: drawingRect, scale: 1.0).draw(in: drawingRect)
    }
}

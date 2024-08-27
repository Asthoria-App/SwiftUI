//
//  StoryEditView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 19.08.2024.
//

import SwiftUI
import UIKit

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
       
            ForEach(draggableImages.indices, id: \.self) { index in
                DraggableImageView(draggableImage: $draggableImages[index], selectedImageIndex: $selectedImageIndex, index: index, hideButtons: $hideButtons)
                    .frame(width: 200, height: 200)
                    .padding(.horizontal, 50)
                    .aspectRatio(contentMode: .fill)
            }
            
            ForEach(draggableStickers.indices, id: \.self) { index in
                DraggableStickerView(draggableSticker: $draggableStickers[index], hideButtons: $hideButtons, deleteArea: CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height - 100, width: 200, height: 200), onDelete: {
                    draggableStickers.remove(at: index)
                 
                })
                .frame(width: 200, height: 200)
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
            
            if !showEyedropper {
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
                                    fontSize: fontSize
                                )
                                draggableTexts.append(newText)
                                selectedTextIndex = draggableTexts.count - 1
                                showOverlay = true
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
            }
            if showDrawingOverlay {
                          DrawingOverlay(showDrawingOverlay: $showDrawingOverlay)
                              .transition(.opacity)
                              .zIndex(1)
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
            }
        }
        
        .sheet(isPresented: $showBackgroundImagePicker) {
            GradientImagePickerView(gradients: gradientOptions, selectedGradient: $selectedGradient, selectedImage: $backgroundImage, showBackgroundImagePicker: $showBackgroundImagePicker)
        }
        .sheet(isPresented: $showDraggableImagePicker) {
            ImagePicker(selectedImage: $selectedDraggableImage)
                .onDisappear {
                    if let selectedImage = selectedDraggableImage {
                        let newImage = DraggableImage(image: selectedImage, position: .zero, scale: 1.0, angle: .zero)
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
                        let newSticker = DraggableSticker(image: selectedStickerImage, position: CGSize(width: 50, height: 100), scale: 1.0, angle: .zero)
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
}

struct DraggableSticker {
    var image: UIImage
    var position: CGSize
    var scale: CGFloat
    var angle: Angle
}

struct DraggableStickerView: View {
    @Binding var draggableSticker: DraggableSticker
    @Binding var hideButtons: Bool
    let deleteArea: CGRect
    var onDelete: () -> Void

    @State private var isDraggingOverDelete: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var shouldRemove: Bool = false

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
                            .scaleEffect(draggableSticker.scale)
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
                                                // Sürüklenen sticker'ı sil
                                                withAnimation(.smooth(duration: 0.7)) {
                                                    shouldRemove = true
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                                    onDelete()
                                                }
                                            } else {
                                                // Yeni pozisyonu kaydet
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
    init(text: String, position: CGSize, scale: CGFloat, angle: Angle, textColor: Color, backgroundColor: Color, backgroundOpacity: CGFloat, font: CustomFont, fontSize: CGFloat) {
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
    }
}

struct BottomSheetStickerPickerView: View {
    @Binding var selectedStickerImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    let stickers: [String] = ["image", "image", "image", "image", "image"]  // Sticker adları
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        ZStack {
            BlurBackground()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Select a Sticker")
                    .font(.headline)
                    .padding()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(stickers.indices, id: \.self) { index in
                            let stickerName = stickers[index]
                            
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
                    .padding()
                }
            }
            .padding()
            .background(Color.black)
            .cornerRadius(10)
            .shadow(radius: 5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
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
                                                // Sürüklenen öğeyi sil, pozisyonu koru
                                                withAnimation(.smooth(duration: 0.7)) {
                                                    shouldRemove = true
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                                    draggableImage = DraggableImage(image: UIImage(), position: draggableImage.position, scale: 1.0, angle: .zero)
                                                }
                                            } else {
                                                // Yeni pozisyonu kaydet
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
                        ColorSelectionView(selectedColor: $textColor, originalColor: $originalTextColor, showEyedropper: $showEyedropper)
                            .padding(.horizontal)
                            .frame(height: 30)
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
    
    let colors: [Color] = [
        .red, .green, .blue, .yellow, .orange, .purple,
        .pink, .cyan, .mint, .teal, .indigo, .brown,
        .gray, .black, .white,
        
        Color(red: 0.75, green: 1.0, blue: 0.0),
        Color(red: 0.93, green: 0.51, blue: 0.93),
        Color(red: 0.87, green: 0.63, blue: 0.87),
        Color(red: 0.5, green: 0.0, blue: 0.0),
        Color(red: 0.5, green: 0.5, blue: 0.0),
        Color(red: 0.0, green: 0.0, blue: 0.5),
        Color(red: 1.0, green: 0.0, blue: 0.5),
        Color(red: 0.0, green: 1.0, blue: 1.0),
        
        Color(red: 0.94, green: 0.90, blue: 0.55),
        Color(red: 0.75, green: 0.75, blue: 0.75),
        Color(red: 1.0, green: 0.5, blue: 0.31),
        Color(red: 1.0, green: 0.75, blue: 0.0),
        Color(red: 0.25, green: 0.88, blue: 0.82),
        Color(red: 0.9, green: 0.9, blue: 0.98),
        Color(red: 1.0, green: 0.64, blue: 0.0),
        Color(red: 0.5, green: 0.5, blue: 1.0),
        Color(red: 0.6, green: 0.4, blue: 0.8),
        Color(red: 0.75, green: 0.85, blue: 0.0)
    ]
    
    var body: some View {
        HStack {
            
            Button(action: {
                showEyedropper.toggle()
            }) {
                Image(systemName: "eyedropper")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.white)
            }
            .frame(width: 35, height: 45)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(colors, id: \.self) { color in
                        ZStack {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 35, height: 35)
                            
                            Circle()
                                .fill(color)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 1.5)
                                )
                                .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 0)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                selectedColor = color
                                originalColor = color
                            }
                        }
                    }
                    
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
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
    var onColorChange: (Color) -> Void  // Yeni closure
    
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
}

struct DrawingOverlay: View {
    @Binding var showDrawingOverlay: Bool
    @State private var currentDrawing: Drawing = Drawing()
    @State private var drawings: [Drawing] = []
    @State private var isDrawing: Bool = true
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
            
            Canvas { context, size in
                for drawing in drawings {
                    var path = Path()
                    path.addLines(drawing.points)
                    context.stroke(path, with: .color(drawing.color), lineWidth: drawing.lineWidth)
                }
                
                var path = Path()
                path.addLines(currentDrawing.points)
                context.stroke(path, with: .color(currentDrawing.color), lineWidth: currentDrawing.lineWidth)
            }
            .gesture(DragGesture(minimumDistance: 0.1)
                .onChanged { value in
                    if isDrawing {
                        currentDrawing.points.append(value.location)
                    }
                }
                .onEnded { _ in
                    drawings.append(currentDrawing)
                    currentDrawing = Drawing()
                }
            )
            
            VStack {
                HStack {
                    Button(action: {
                        showDrawingOverlay = false
                    }) {
                        Text("Back")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    
                    Button(action: {
                        // Bitir işlemi
                        showDrawingOverlay = false
                    }) {
                        Text("Done")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        isDrawing = true
                    }) {
                        Image(systemName: "pencil")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        isDrawing = false
                    }) {
                        Image(systemName: "eraser")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

struct Drawing {
    var points: [CGPoint] = []
    var color: Color = .white
    var lineWidth: CGFloat = 3.0
}

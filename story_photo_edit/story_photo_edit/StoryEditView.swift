//
//  StoryEditView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 19.08.2024.
//
import SwiftUI
import PhotosUI

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
    @State private var selectedFont: Font = .body
    @State private var showBackgroundImagePicker: Bool = false
    @State private var showDraggableImagePicker: Bool = false
    @State private var backgroundImage: UIImage? = nil
    @State private var selectedDraggableImage: UIImage? = nil
    @State private var imagePosition: CGSize = .zero
    @State private var imageScale: CGFloat = 1.0
    @State private var imageAngle: Angle = .zero
    @State private var imageShowDeleteButton: Bool = false
    @State private var selectedGradient: LinearGradient? = nil
    
    let gradientOptions: [LinearGradient] = [
        LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [.green, .yellow]), startPoint: .top, endPoint: .bottom)
    ]

    var body: some View {
        ZStack {
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

            VStack {
                HStack {
                    if !hideButtons {
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
                    }

                    Spacer()

                    if !hideButtons {
                        Button(action: {
                            showOverlay.toggle()
                        }) {
                            Image(systemName: "textformat")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.white)
                        }
                        .frame(width: 35, height: 35)
                    }

                    if !hideButtons {
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
                }
                .frame(width: UIScreen.main.bounds.width)
                .padding(.top, 20)

                Spacer()
            }

            if !showOverlay {
                DraggableTextView(userText: $userText, textPosition: $textPosition, scale: $scale, angle: $angle, showDeleteButton: $showDeleteButton, hideButtons: $hideButtons, showOverlay: $showOverlay, textColor: $textColor, backgroundOpacity: $backgroundOpacity, selectedFont: $selectedFont)
                    .padding(.horizontal, 50)
            }

            if let selectedDraggableImage = selectedDraggableImage {
                DraggableImageView(selectedImage: $selectedDraggableImage, imagePosition: $imagePosition, scale: $imageScale, angle: $imageAngle, showDeleteButton: $imageShowDeleteButton, hideButtons: $hideButtons)
                    .frame(width: 90, height: 90)
                    .padding(.horizontal, 50)
            }

            if showOverlay {
                OverlayView(showOverlay: $showOverlay, userText: $userText, textColor: $textColor, backgroundOpacity: $backgroundOpacity, selectedFont: $selectedFont)
            }
        }
        .sheet(isPresented: $showBackgroundImagePicker) {
            GradientImagePickerView(gradients: gradientOptions, selectedGradient: $selectedGradient, selectedImage: $backgroundImage, showBackgroundImagePicker: $showBackgroundImagePicker)
        }
        .sheet(isPresented: $showDraggableImagePicker) {
            ImagePicker(selectedImage: $selectedDraggableImage)
        }
        .onChange(of: showOverlay) { newValue in
            hideButtons = newValue
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
                            selectedImage = nil // Galeri seçimini sıfırla
                            showBackgroundImagePicker = false // Sayfayı kapat
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
    @Binding var selectedImage: UIImage?
    @Binding var imagePosition: CGSize
    @Binding var scale: CGFloat
    @Binding var angle: Angle
    @Binding var showDeleteButton: Bool
    @Binding var hideButtons: Bool

    @State private var lastScaleValue: CGFloat = 1.0
    @State private var currentDragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(lastScaleValue * scale)
                            .rotationEffect(angle)
                            .overlay(
                                GeometryReader { imgGeometry in
                                    if showDeleteButton {
                                        
                                        let imgSize = imgGeometry.size
                                        let scaledSize = CGSize(
                                            width: imgSize.width * lastScaleValue * scale,
                                            height: imgSize.height * lastScaleValue * scale
                                        )
                                        
                                        let halfWidth = scaledSize.width / 2
                                        let halfHeight = scaledSize.height / 2
                                        let radians = CGFloat(angle.radians)
                                        
                                        let cosValue = cos(radians)
                                        let sinValue = sin(radians)
                                        
                                        let rotatedX = halfWidth * cosValue - (-halfHeight) * sinValue
                                        let rotatedY = halfWidth * sinValue + (-halfHeight) * cosValue
                                        
                                        let topRightCornerX = rotatedX + geometry.size.width / 2
                                        let topRightCornerY = rotatedY + geometry.size.height / 2
                                        
                                        Button(action: {
                                            if self.selectedImage != nil {
                                                self.selectedImage = nil
                                                  scale = 1.0
                                                  angle = .zero
                                                  showDeleteButton = false
                                                  imagePosition = .zero
                                              }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(.white)
                                        }
                                        .position(x: topRightCornerX, y: topRightCornerY)
                                    }
                                }
                            )
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
                                            
                                            imagePosition = CGSize(
                                                width: currentDragOffset.width + inverseTranslation.width / lastScaleValue,
                                                height: currentDragOffset.height + inverseTranslation.height / lastScaleValue
                                            )
                                        }
                                        .onEnded { value in
                                            hideButtons = false
                                            currentDragOffset = imagePosition
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
                            }
                            .onLongPressGesture {
                                showDeleteButton = true
                            }
                    }
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
        let x = geometry.size.width / 2 + imagePosition.width
        let y = geometry.size.height / 2 + imagePosition.height
        return CGPoint(x: x, y: y)
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
    @Binding var backgroundOpacity: CGFloat
    @Binding var selectedFont: Font

    @State private var lastScaleValue: CGFloat = 1.0
    @State private var currentDragOffset: CGSize = .zero
    @State private var initialDragPosition: CGSize = .zero

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    Text(userText)
                        .font(selectedFont)
                        .foregroundColor(textColor)
                        .padding(10)
                        .background(Color.white.opacity(backgroundOpacity))
                        .cornerRadius(10)
                        .overlay(
                            GeometryReader { textGeometry in
                                if showDeleteButton {
                                    Button(action: {
                                        userText = ""
                                        backgroundOpacity = 0
                                        showDeleteButton = false
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(.white)
                                    }
                                    .offset(x: textGeometry.size.width - 12.5, y: -12.5)
                                }
                            }
                        )
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
                                    }
                                    .onEnded { value in
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
                        }
                        .onLongPressGesture {
                            showDeleteButton = true
                        }
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
    @Binding var backgroundOpacity: CGFloat
    @Binding var selectedFont: Font
    @State private var textHeight: CGFloat = 30

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
                            .padding(5)
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
                            backgroundOpacity = backgroundOpacity == 0 ? 1.0 : 0
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
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.clear)

                Spacer()

                DynamicHeightTextView(text: $userText, minHeight: 30, maxHeight: 150, textHeight: $textHeight, textColor: $textColor, backgroundOpacity: $backgroundOpacity, selectedFont: $selectedFont)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: textHeight)
                    .padding(7)
                    .background(Color.clear)
                    .cornerRadius(10)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            focusTextView()
                        }
                    }

                if showColorCollection {
                    ColorSelectionView(selectedColor: $textColor)
                        .padding(.horizontal)
                        .frame(height: 30)
                        .background(Color.white.opacity(0.0))
                        .cornerRadius(10)
                        .padding(.bottom, 5)
                }

                if showFontCollection {
                    FontCollectionView(selectedFont: $selectedFont)
                        .padding(.horizontal)
                        .frame(height: 35)
                        .background(Color.white.opacity(0.0))
                        .cornerRadius(10)
                        .padding(.bottom, 60)
                }
            }
            .padding(.top, 0)
        }
    }

    private func textWidth() -> CGFloat {
        let font = UIFont(descriptor: selectedFont.uiFontDescriptor, size: 20)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (userText as NSString).size(withAttributes: attributes)
        return size.width
    }
}

struct DynamicHeightTextView: UIViewRepresentable {
    @Binding var text: String
    var minHeight: CGFloat
    var maxHeight: CGFloat
    @Binding var textHeight: CGFloat
    @Binding var textColor: Color
    @Binding var backgroundOpacity: CGFloat
    @Binding var selectedFont: Font // Added selectedFont

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: DynamicHeightTextView

        init(_ parent: DynamicHeightTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
            self.parent.textHeight = max(self.parent.minHeight, min(size.height, self.parent.maxHeight))
            self.parent.text = textView.text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.font = UIFont(descriptor: selectedFont.uiFontDescriptor, size: 20)
        textView.delegate = context.coordinator
        textView.text = text
        textView.backgroundColor = UIColor.white.withAlphaComponent(backgroundOpacity)
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 10
        textView.textColor = UIColor(textColor)
        textView.becomeFirstResponder()
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.textColor = UIColor(textColor)
        uiView.backgroundColor = UIColor.white.withAlphaComponent(backgroundOpacity)
        uiView.font = UIFont(descriptor: selectedFont.uiFontDescriptor, size: 20)
        let size = uiView.sizeThatFits(CGSize(width: uiView.frame.width, height: .infinity))
        DispatchQueue.main.async {
            self.textHeight = max(self.minHeight, min(size.height, self.maxHeight))
        }
    }
}

struct ColorSelectionView: View {
    @Binding var selectedColor: Color

    let colors: [Color] = [
        .red, .green, .blue, .yellow, .orange, .purple,
        .pink, .cyan, .mint, .teal, .indigo, .brown,
        .gray, .black, .white,

        Color(red: 0.75, green: 1.0, blue: 0.0),     // Lime
        Color(red: 0.93, green: 0.51, blue: 0.93),   // Violet
        Color(red: 0.87, green: 0.63, blue: 0.87),   // Plum
        Color(red: 0.5, green: 0.0, blue: 0.0),      // Maroon
        Color(red: 0.5, green: 0.5, blue: 0.0),      // Olive
        Color(red: 0.0, green: 0.0, blue: 0.5),      // Navy
        Color(red: 1.0, green: 0.0, blue: 0.5),      // Rose
        Color(red: 0.0, green: 1.0, blue: 1.0),      // Aqua
        
        Color(red: 0.94, green: 0.90, blue: 0.55),   // Gold
        Color(red: 0.75, green: 0.75, blue: 0.75),   // Silver
        Color(red: 1.0, green: 0.5, blue: 0.31),     // Coral
        Color(red: 1.0, green: 0.75, blue: 0.0),     // Amber
        Color(red: 0.25, green: 0.88, blue: 0.82),   // Turquoise
        Color(red: 0.9, green: 0.9, blue: 0.98),     // Lavender
        Color(red: 1.0, green: 0.64, blue: 0.0),     // Orange
        Color(red: 0.5, green: 0.5, blue: 1.0),      // Light Blue
        Color(red: 0.6, green: 0.4, blue: 0.8),      // Purple Haze
        Color(red: 0.75, green: 0.85, blue: 0.0)     // Chartreuse
    ]


    var body: some View {
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
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            selectedColor = color
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
    }
}

struct FontCollectionView: View {
    @Binding var selectedFont: Font

    let fonts: [Font] = [.headline, .headline, .body, .footnote]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(fonts, id: \.self) { font in
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 35, height: 35)

                        Text("Aa")
                            .font(font)
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

extension Font {
    var uiFontDescriptor: UIFontDescriptor {
        switch self {
        case .largeTitle: return UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
        case .title: return UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1)
        case .headline: return UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline)
        case .body: return UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        default: return UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        }
    }
}
import SwiftUI

struct CustomTextFieldView: UIViewRepresentable {

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.placeholder = "Enter Text"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor.white
        textField.returnKeyType = .done
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        // Nothing to update
    }
}


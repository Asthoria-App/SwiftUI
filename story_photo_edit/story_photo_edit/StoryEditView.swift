//
//  StoryEditView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 19.08.2024.
//

import SwiftUI
import UIKit
import PencilKit

enum DraggableType {
    case text, image, sticker, drawing
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
    @State private var fontSize: CGFloat = 34
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
    @State private var drawingImagesPositions: [CGRect] = []
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
                
            } else if let selectedGradient = selectedGradient {
                selectedGradient
                    .edgesIgnoringSafeArea(.all)
                
            } else {
                
                Image("image")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
            }
            ForEach(drawingImages.indices, id: \.self) { index in
                Image(uiImage: drawingImages[index])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: drawingImagesPositions[index].width, height: drawingImagesPositions[index].height)
                    .position(x: drawingImagesPositions[index].midX, y: drawingImagesPositions[index].midY)
                    .zIndex(globalIndex)
                    .background(
                        Color.red
                            .frame(width: drawingImagesPositions[index].width, height: drawingImagesPositions[index].height)
                            .position(x: drawingImagesPositions[index].midX, y: drawingImagesPositions[index].midY)
                    )
            }


            
            ForEach(draggableImages.indices, id: \.self) { index in
                DraggableImageView(draggableImage: $draggableImages[index], selectedImageIndex: $selectedImageIndex, index: index, hideButtons: $hideButtons)
                    .frame(width: 200, height: 200)
                    .padding(5)
                    .aspectRatio(contentMode: .fill)
                    .zIndex(draggableImages[index].zIndex)
            }
            
            ForEach(draggableStickers.indices, id: \.self) { index in
                DraggableStickerView(draggableSticker: $draggableStickers[index], hideButtons: $hideButtons, deleteArea: CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height - 100, width: 200, height: 200), onDelete: {
                    draggableStickers.remove(at: index)
                })
                .frame(width: 200, height: 200)
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
                        GeometryReader { geometry in
                            DrawingOverlay(showDrawingOverlay: $showDrawingOverlay) { drawingImage, drawingRect in
                                if let image = drawingImage, let rect = drawingRect {
                                    globalIndex += 1
                                    drawingImages.append(image)
                                    drawingImagesPositions.append(rect)
                                    
                                    print("Position: \(rect.origin), Size: \(rect.size)")
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
    var onComplete: (UIImage?, CGRect?) -> Void
    @State private var canvasView = PKCanvasView()
    @State private var drawings: [PKDrawing] = []

    enum ToolType {
        case pen, crayon, marker, watercolor, eraser
    }

    var body: some View {
        ZStack {
            DrawingView(tool: $tool, canvasView: $canvasView, drawings: $drawings)

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
                        let drawingRect = boundingBoxForDrawing(in: canvasView)
                        print("Drawing Rect: \(drawingRect)")
                        let drawingImage = captureDrawing(from: canvasView, in: drawingRect)
                        showDrawingOverlay = false
                        onComplete(drawingImage, drawingRect)
                    }
                    .foregroundColor(.white)
                }
                .padding()

                Spacer()

                ColorSelectionView(
                    selectedColor: $toolColor,
                    originalColor: $toolColor,
                    onColorSelected: { color in
                        toolColor = color
                        updateTool()
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
func boundingBoxForDrawing(in view: PKCanvasView) -> CGRect {
    let drawing = view.drawing
    let bounds = drawing.bounds
    
    let adjustedBounds = view.bounds.intersection(bounds)
    return adjustedBounds
}

func captureDrawing(from view: PKCanvasView, in rect: CGRect) -> UIImage? {
    let adjustedRect = rect.intersection(view.bounds)
    let renderer = UIGraphicsImageRenderer(size: adjustedRect.size)
    return renderer.image { context in
        view.drawing.image(from: adjustedRect, scale: 1.0).draw(in: CGRect(origin: .zero, size: adjustedRect.size))
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


//
//  DrawingOverlayView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 29.08.2024.
//

import SwiftUI
import PencilKit


struct DrawingOverlay: View {
    @Binding var showDrawingOverlay: Bool
    @Binding var hideButtons: Bool
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
                    
                    Button(action: {
                        undoLastDrawing()
                    }) {
                        Text("Back")
                            .font(Font.system(size: 21, weight: .medium))
                            .padding(7)
                            .foregroundColor(.white)
                    }
                    
            
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

                    Button(action: {
                        let drawingRect = boundingBoxForDrawing(in: canvasView)
                        print("Drawing Rect: \(drawingRect)")
                        let drawingImage = captureDrawing(from: canvasView, in: drawingRect)
                        showDrawingOverlay = false
                        hideButtons = false
                        onComplete(drawingImage, drawingRect)
                    }) {
                        Text("Done")
                            .font(Font.system(size: 21, weight: .medium))
                            .padding(7)
                            .foregroundColor(.white)
                    }
                    
                  
                   
                }
                .padding(10)

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



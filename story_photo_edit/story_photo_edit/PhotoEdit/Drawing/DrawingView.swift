//
//  DrawingView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 29.08.2024.
//

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

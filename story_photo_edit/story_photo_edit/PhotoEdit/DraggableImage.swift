//
//  DraggableImage.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 29.08.2024.
//

import SwiftUI

struct DraggableImage {
    var image: UIImage
    var position: CGSize
    var scale: CGFloat
    var angle: Angle
    var lastScaleValue: CGFloat = 1.0
    var zIndex: CGFloat
    var globalFrame: CGRect = .zero
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
                            .cornerRadius(7)
                            .clipped()
                            .scaleEffect(draggableImage.lastScaleValue * draggableImage.scale)
                            .rotationEffect(draggableImage.angle)
                            .position(x: geometry.size.width / 2 + draggableImage.position.width + dragOffset.width,
                                      y: geometry.size.height / 2 + draggableImage.position.height + dragOffset.height)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            let scale = draggableImage.lastScaleValue * draggableImage.scale
                                            let globalFrame = geo.frame(in: .global)
                                            draggableImage.globalFrame = CGRect(
                                                origin: globalFrame.origin,
                                                size: CGSize(width: globalFrame.width * scale, height: globalFrame.height * scale)
                                            )
                                            print("Image Global Frame: \(draggableImage.globalFrame)")
                                        }
                                }
                            )
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
                                                withAnimation(.smooth(duration: 0.3)) {
                                                    shouldRemove = true
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    draggableImage = DraggableImage(image: UIImage(), position: draggableImage.position, scale: 1.0, angle: .zero, zIndex: CGFloat(selectedImageIndex!))
                                                }
                                            } else {
                                                draggableImage.position.width += dragOffset.width
                                                draggableImage.position.height += dragOffset.height
                                                dragOffset = .zero
                                                updateImageState(geo: geometry)

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

                                            updateImageState(geo: geometry)

                                            
                                        }
                                )
                                .simultaneously(with: MagnificationGesture()
                                    .onChanged { value in
                                        draggableImage.scale = value
                                    }
                                    .onEnded { _ in
                                        draggableImage.lastScaleValue *= draggableImage.scale
                                        draggableImage.scale = 1.0
                                        updateImageState(geo: geometry)

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
    
    
    private func updateImageState(geo: GeometryProxy) {
        let scale = draggableImage.lastScaleValue * draggableImage.scale
        
        let transformedSize = CGSize(width: geo.size.width * scale, height: geo.size.height * scale)
        
        let offsetX = (geo.size.width * scale - geo.size.width) / 2
        let offsetY = (geo.size.height * scale - geo.size.height) / 2

        draggableImage.globalFrame = CGRect(
            origin: CGPoint(
                x: geo.frame(in: .global).origin.x + dragOffset.width + draggableImage.position.width - offsetX,
                y: geo.frame(in: .global).origin.y + dragOffset.height + draggableImage.position.height - offsetY
            ),
            size: transformedSize
        )
    }
}
struct DraggableDrawing {
    var image: UIImage
    var position: CGRect
    var scale: CGFloat
    var angle: Angle
    var lastScaleValue: CGFloat = 1.0
    var zIndex: CGFloat
    var globalFrame: CGRect = .zero
}

struct DraggableDrawingView: View {
    @Binding var draggableDrawing: DraggableDrawing
    @Binding var selectedDrawingIndex: Int?
    var index: Int
    @Binding var hideButtons: Bool
    
    @State private var isDraggingOverDelete: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var shouldRemove: Bool = false
    @State private var currentAngle: Angle = .zero

    var body: some View {
        GeometryReader { geometry in
            if !shouldRemove {
                ZStack {
                    Color.clear
                        .frame(width: draggableDrawing.position.width, height: draggableDrawing.position.height)
                        .position(x: draggableDrawing.position.midX + dragOffset.width,
                                  y: draggableDrawing.position.midY + dragOffset.height)

                    Image(uiImage: draggableDrawing.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: draggableDrawing.position.width, height: draggableDrawing.position.height)
                        .clipped()
                        .scaleEffect(draggableDrawing.lastScaleValue * draggableDrawing.scale)
                        .rotationEffect(draggableDrawing.angle + currentAngle)
                        .position(x: draggableDrawing.position.midX + dragOffset.width,
                                  y: draggableDrawing.position.midY + dragOffset.height)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        updateDrawingState(geo: geo)
                                    }
                            }
                        )
                }
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
                                    withAnimation(.smooth(duration: 0.3)) {
                                        shouldRemove = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        draggableDrawing = DraggableDrawing(image: UIImage(), position: draggableDrawing.position, scale: 1.0, angle: .zero, zIndex: CGFloat(selectedDrawingIndex!))
                                    }
                                } else {
                                    draggableDrawing.position = CGRect(x: draggableDrawing.position.origin.x + dragOffset.width,
                                                                       y: draggableDrawing.position.origin.y + dragOffset.height,
                                                                       width: draggableDrawing.position.width,
                                                                       height: draggableDrawing.position.height)
                                    dragOffset = .zero
                                    updateDrawingState(geo: geometry)
                                }
                                dragOffset = .zero
                                hideButtons = false
                                isDraggingOverDelete = false
                            },
                        RotationGesture()
                            .onChanged { newAngle in
                                currentAngle = newAngle
                            }
                            .onEnded { newAngle in
                                draggableDrawing.angle += currentAngle
                                currentAngle = .zero
                                updateDrawingState(geo: geometry)
                            }
                    )
                    .simultaneously(with: MagnificationGesture()
                        .onChanged { value in
                            draggableDrawing.scale = value
                        }
                        .onEnded { _ in
                            draggableDrawing.lastScaleValue *= draggableDrawing.scale
                            draggableDrawing.scale = 1.0
                            updateDrawingState(geo: geometry)
                        }
                    )
                )
                .onTapGesture {
                    selectedDrawingIndex = index
                }
            }
        }
    }
    
    private func updateDrawingState(geo: GeometryProxy) {
        let scale = draggableDrawing.lastScaleValue * draggableDrawing.scale

        let transformedSize = CGSize(
            width: draggableDrawing.position.width * scale,
            height: draggableDrawing.position.height * scale
        )

        let globalOrigin = CGPoint(
            x: geo.frame(in: .global).origin.x + dragOffset.width + (draggableDrawing.position.width - transformedSize.width) / 2,
            y: geo.frame(in: .global).origin.y + dragOffset.height + (draggableDrawing.position.height - transformedSize.height) / 2
        )

        draggableDrawing.globalFrame = CGRect(
            origin: globalOrigin,
            size: transformedSize
        )

        print("Updated Drawing Global Frame: \(draggableDrawing.globalFrame)")
    }
}

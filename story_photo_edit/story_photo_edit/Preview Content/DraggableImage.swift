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


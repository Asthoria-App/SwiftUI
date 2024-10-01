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
    @State private var currentAngle: Angle = .zero

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
                                            draggableImage.angle = currentAngle + newAngle
                                        }
                                        .onEnded { newAngle in
                                            currentAngle += newAngle
                                            updateImageState(geo: geometry)
                                            if hideButtons == true {
                                                hideButtons = false
                                            }
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

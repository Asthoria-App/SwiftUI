//
//  DraggableTime.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 10.09.2024.
//

import SwiftUI

struct DraggableTime {
    var image: UIImage
    var position: CGSize
    var scale: CGFloat
    var angle: Angle
    var lastScaleValue: CGFloat = 1.0
    var zIndex: CGFloat
    var globalFrame: CGRect = .zero
}
struct DraggableTimeView: View {
    @Binding var draggableTime: DraggableTime
    @Binding var selectedTimeIndex: Int?
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
                        Image(uiImage: draggableTime.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 60) // Customized size for time
                            .cornerRadius(5)
                            .clipped()
                            .scaleEffect(draggableTime.lastScaleValue * draggableTime.scale)
                            .rotationEffect(draggableTime.angle)
                            .position(x: geometry.size.width / 2 + draggableTime.position.width + dragOffset.width,
                                      y: geometry.size.height / 2 + draggableTime.position.height + dragOffset.height)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            let scale = draggableTime.lastScaleValue * draggableTime.scale
                                            let globalFrame = geo.frame(in: .global)
                                            draggableTime.globalFrame = CGRect(
                                                origin: globalFrame.origin,
                                                size: CGSize(width: globalFrame.width * scale, height: globalFrame.height * scale)
                                            )
                                            print("Time Global Frame: \(draggableTime.globalFrame)")
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
                                                    draggableTime = DraggableTime(image: UIImage(), position: draggableTime.position, scale: 1.0, angle: .zero, zIndex: CGFloat(selectedTimeIndex!))
                                                }
                                            } else {
                                                draggableTime.position.width += dragOffset.width
                                                draggableTime.position.height += dragOffset.height
                                                dragOffset = .zero
                                                updateTimeState(geo: geometry)
                                            }
                                            dragOffset = .zero
                                            hideButtons = false
                                            isDraggingOverDelete = false
                                        },
                                    RotationGesture()
                                        .onChanged { newAngle in
                                            draggableTime.angle += newAngle - draggableTime.angle
                                        }
                                        .onEnded { newAngle in
                                            draggableTime.angle = newAngle
                                            updateTimeState(geo: geometry)
                                        }
                                )
                                .simultaneously(with: MagnificationGesture()
                                    .onChanged { value in
                                        draggableTime.scale = value
                                    }
                                    .onEnded { _ in
                                        draggableTime.lastScaleValue *= draggableTime.scale
                                        draggableTime.scale = 1.0
                                        updateTimeState(geo: geometry)
                                    }
                                )
                            )
                            .onTapGesture {
                                selectedTimeIndex = index
                            }
                    }
                }
            }
        }
    }
    
    private func updateTimeState(geo: GeometryProxy) {
        let scale = draggableTime.lastScaleValue * draggableTime.scale
        let globalFrame = geo.frame(in: .global)
        draggableTime.globalFrame = CGRect(
            origin: globalFrame.origin,
            size: CGSize(width: globalFrame.width * scale, height: globalFrame.height * scale)
        )
    }
}

//
//  DraggableText.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 29.08.2024.
//

import SwiftUI
import SwiftUI

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
    var lastScale: CGFloat
}

struct DraggableTextView: View {
    
    @Binding var draggableText: DraggableText
    @Binding var hideButtons: Bool
    @Binding var showOverlay: Bool
    @Binding var selectedTextIndex: Int?
    
    @State private var isDraggingOverDelete: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var shouldRemove: Bool = false
    @State private var currentAngle: Angle = .zero

    var index: Int
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    if !shouldRemove {
                        ZStack {
                            Text(verbatim: draggableText.text)
                                .onAppear() {
                                    selectedTextIndex = index
                                }
                                .foregroundColor(draggableText.textColor)
                                .font(draggableText.font.toSwiftUIFont(size: draggableText.fontSize))
                                .padding(6)
                                .background(draggableText.backgroundColor.opacity(draggableText.backgroundOpacity)
                                    .cornerRadius(5))
                                .scaleEffect(draggableText.lastScale * draggableText.scale)
                                .rotationEffect(draggableText.angle)
                                .position(x: geometry.size.width / 2 + draggableText.position.width + dragOffset.width,
                                          y: geometry.size.height / 2 + draggableText.position.height + dragOffset.height)
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
                                                        if let selectedIndex = selectedTextIndex {
                                                            draggableText = DraggableText(
                                                                text: "",
                                                                position: .zero,
                                                                scale: .zero,
                                                                angle: .zero,
                                                                textColor: .clear,
                                                                backgroundColor: .clear,
                                                                backgroundOpacity: 0.0,
                                                                font: .forum,
                                                                fontSize: .zero,
                                                                originalTextColor: .clear,
                                                                zIndex: 1,
                                                                lastScale: .zero)
                                                        }
                                                    }
                                                } else {
                                                    draggableText.position.width += dragOffset.width
                                                    draggableText.position.height += dragOffset.height
                                                }
                                                dragOffset = .zero
                                                hideButtons = false
                                                isDraggingOverDelete = false
                                            },
                                        RotationGesture()
                                            .onChanged { newAngle in
                                                draggableText.angle = currentAngle + newAngle
                                            }
                                            .onEnded { newAngle in
                                                currentAngle += newAngle
                                                if hideButtons == true {
                                                    hideButtons = false
                                                }
                                            }
                                    )
                                    .simultaneously(with: MagnificationGesture()
                                        .onChanged { value in
                                            draggableText.scale = value
                                        }
                                        .onEnded { _ in
                                            draggableText.lastScale *= draggableText.scale
                                            draggableText.scale = 1.0
                                        }
                                    )
                                )
                                .onTapGesture {
                                    hideButtons = false
                                    showOverlay = true
                                    selectedTextIndex = index
                                }
                        }
                    }
                }
            }
        }
    }
}

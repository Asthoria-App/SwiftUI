//
//  DraggableText.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 29.08.2024.
//

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
    var globalFrame: CGRect = .zero
    var lastScale: CGFloat

}

struct DraggableTextView: View {
    @Binding var draggableText: DraggableText
    @Binding var hideButtons: Bool

    @State private var isDraggingOverDelete: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var shouldRemove: Bool = false
    @State private var tapCount: Int = 0

    @Binding var selectedTextIndex: Int?

    let gradientColor = LinearGradient(
        gradient: Gradient(colors: [.red, .blue]),
        startPoint: .leading,
        endPoint: .trailing
    )



    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    if !shouldRemove {
                        ZStack {
                       
                            Text(verbatim: draggableText.text)
                                .font(Font.system(size: 26))
                            .foregroundColor( draggableText.textColor)
                          
                            .padding(6)
                            .background(draggableText.backgroundColor.opacity(0.6))
                         
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
                                                    draggableText = DraggableText(
                                                        text: draggableText.text,
                                                        position: draggableText.position,
                                                        scale: draggableText.scale,
                                                        angle: draggableText.angle,
                                                        textColor: draggableText.textColor,
                                                        backgroundColor: draggableText.backgroundColor,
                                                        backgroundOpacity: draggableText.backgroundOpacity,
                                                        font: draggableText.font,
                                                        fontSize: draggableText.fontSize,
                                                        originalTextColor: draggableText.originalTextColor,
                                                        zIndex: draggableText.zIndex,
                                                        globalFrame: draggableText.globalFrame,
                                                        lastScale: draggableText.lastScale)
                                                }
                                            } else {
                                                draggableText.position.width += dragOffset.width
                                                draggableText.position.height += dragOffset.height
                                                dragOffset = .zero
                                                updateTextState(geo: geometry)
                                            }
                                            dragOffset = .zero
                                            hideButtons = false
                                            isDraggingOverDelete = false
                                        },
                                    RotationGesture()
                                        .onChanged { newAngle in
                                            draggableText.angle += newAngle - draggableText.angle
                                        }
                                        .onEnded { newAngle in
                                            draggableText.angle = newAngle
                                            updateTextState(geo: geometry)
                                        }
                                )
                                .simultaneously(with: MagnificationGesture()
                                    .onChanged { value in
                                        draggableText.scale = value
                                    }
                                    .onEnded { _ in
                                        draggableText.lastScale *= draggableText.scale
                                        draggableText.scale = 1.0
                                        updateTextState(geo: geometry)
                                    }
                                )
                            )
                            .onTapGesture {
                                tapCount += 1
                            }
                        }
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        let scale = draggableText.lastScale * draggableText.scale
                                        let globalFrame = geo.frame(in: .global)
                                        
                                        draggableText.position = CGSize(
                                            width: -geo.size.width / 2 + globalFrame.width * scale / 2,
                                            height: -geo.size.height / 2 + globalFrame.height * scale / 2
                                        )
                                        
                                        draggableText.globalFrame = CGRect(
                                            origin: globalFrame.origin,
                                            size: CGSize(width: globalFrame.width * scale, height: globalFrame.height * scale)
                                        )
                                        
                                        updateTextState(geo: geo)
                                    }
                            }
                        )
                    }
                }
            }
        }
    }


    private func updateTextState(geo: GeometryProxy) {
        let scale = draggableText.lastScale * draggableText.scale
        
        let transformedSize = CGSize(width: geo.size.width * scale, height: geo.size.height * scale)
        
        let offsetX = (geo.size.width * scale - geo.size.width) / 2
        let offsetY = (geo.size.height * scale - geo.size.height) / 2
        
        draggableText.globalFrame = CGRect(
            origin: CGPoint(
                x: geo.frame(in: .global).origin.x + dragOffset.width + draggableText.position.width - offsetX,
                y: geo.frame(in: .global).origin.y + dragOffset.height + draggableText.position.height - offsetY
            ),
            size: transformedSize
        )
        print("Updated Location Global Frame: \(draggableText.globalFrame)")
    }
}

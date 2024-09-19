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

    
    init(text: String, position: CGSize, scale: CGFloat, angle: Angle, textColor: Color, backgroundColor: Color, backgroundOpacity: CGFloat, font: CustomFont, fontSize: CGFloat, zIndex: CGFloat, lastScale: CGFloat) {
        self.text = text
        self.position = position
        self.scale = scale
        self.angle = angle
        self.textColor = textColor
        self.originalTextColor = textColor
        self.backgroundColor = backgroundColor
        self.backgroundOpacity = backgroundOpacity
        self.font = font
        self.fontSize = fontSize
        self.zIndex = zIndex
        self.lastScale = lastScale
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
    @Binding var backgroundColor: Color
    @Binding var backgroundOpacity: CGFloat
    @Binding var selectedFont: CustomFont
    @Binding var fontSize: CGFloat
    var index: Int
    @Binding var selectedTextIndex: Int?
    
    @Binding var lastScaleValue: CGFloat
    @State private var currentDragOffset: CGSize = .zero
    @State private var isDraggingOverDelete: Bool = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Text(userText)
                    .font(selectedFont.toSwiftUIFont(size: fontSize))
                    .foregroundColor(textColor)
                    .padding(8)
                    .background(backgroundColor.opacity(backgroundOpacity))
                    .position(positionInBounds(geometry))
                    .scaleEffect(lastScaleValue * scale)
                    .rotationEffect(angle)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    updateTextState(geo: geo)
                                }
                        }
                    )
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
                                    
                                    let deleteAreaFrame = CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height - 100, width: 200, height: 200)
                                    if deleteAreaFrame.contains(CGPoint(x: value.location.x, y: value.location.y)) {
                                        isDraggingOverDelete = true
                                    } else {
                                        isDraggingOverDelete = false
                                    }
                                }
                                .onEnded { value in
                                    if isDraggingOverDelete {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation(.smooth(duration: 0.3)) {
                                                scale = 0.4
                                            }
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                            userText = ""
                                            textColor = .white
                                            textPosition = .zero
                                            backgroundOpacity = 0
                                            scale = 1.0
                                        }
                                    } else {
                                        print("Text not dropped on delete button!")
                                    }
                                    isDraggingOverDelete = false
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
                                updateTextState(geo: geometry)
                            }
                        )
                    )
                    .onTapGesture {
                        hideButtons = false
                        showOverlay = true
                        selectedTextIndex = index
                    }
                    .onLongPressGesture {
                        showDeleteButton = true
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

    private func updateTextState(geo: GeometryProxy) {
     
        let updatedScale = lastScaleValue * scale
      
        let transformedSize = CGSize(width: geo.size.width * updatedScale, height: geo.size.height * updatedScale)
        
        let offsetX = (geo.size.width * updatedScale - geo.size.width) / 2
        let offsetY = (geo.size.height * updatedScale - geo.size.height) / 2

        let globalFrame = CGRect(
            origin: CGPoint(
                x: geo.frame(in: .global).origin.x + textPosition.width - offsetX,
                y: geo.frame(in: .global).origin.y + textPosition.height - offsetY
            ),
            size: transformedSize
        )
        
        print("Updated Text Global Frame: \(globalFrame)")
        
    }


}

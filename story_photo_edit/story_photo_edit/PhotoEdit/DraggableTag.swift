//
//  DraggableTag.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 11.09.2024.
//

import SwiftUI

struct DraggableTag {
    var text: String
    var position: CGSize
    var scale: CGFloat
    var angle: Angle
    var lastScaleValue: CGFloat = 1.0
    var zIndex: CGFloat
    var globalFrame: CGRect = .zero
    var backgroundColor: Color = .black
    var textColor: Color = .white
    var useGradientText: Bool = false
    var originalText: String
    var image: UIImage

    
}

struct DraggableTagView: View {
    @Binding var draggableTag: DraggableTag
    @Binding var hideButtons: Bool

    @State private var isDraggingOverDelete: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var shouldRemove: Bool = false
    @State private var tapCount: Int = 0

    @Binding var selectedTagIndex: Int?

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
                       
                            Text(verbatim: draggableTag.text)
                                .font(Font.system(size: 26))
                            .foregroundColor(draggableTag.useGradientText ? .clear : draggableTag.textColor)
                            .overlay(
                                draggableTag.useGradientText ?
                                gradientColor.mask(Text(draggableTag.text).font(.system(size: 26))) : nil
                            )
                            .padding(6)
                            .background(draggableTag.backgroundColor.opacity(0.6))
                            .cornerRadius(5)
                            .scaleEffect(draggableTag.lastScaleValue * draggableTag.scale) // Apply the scale effect
                            .rotationEffect(draggableTag.angle)
                            .position(x: geometry.size.width / 2 + draggableTag.position.width + dragOffset.width,
                                      y: geometry.size.height / 2 + draggableTag.position.height + dragOffset.height)
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
                                                    draggableTag = DraggableTag(text: draggableTag.text, position: draggableTag.position, scale: draggableTag.scale, angle: draggableTag.angle, zIndex: draggableTag.zIndex, originalText: draggableTag.originalText, image: draggableTag.image)
                                                }
                                            } else {
                                                draggableTag.position.width += dragOffset.width
                                                draggableTag.position.height += dragOffset.height
                                                dragOffset = .zero
                                                updateTagState(geo: geometry)
                                            }
                                            dragOffset = .zero
                                            hideButtons = false
                                            isDraggingOverDelete = false
                                        },
                                    RotationGesture()
                                        .onChanged { newAngle in
                                            draggableTag.angle += newAngle - draggableTag.angle
                                        }
                                        .onEnded { newAngle in
                                            draggableTag.angle = newAngle
                                            updateTagState(geo: geometry)
                                        }
                                )
                                .simultaneously(with: MagnificationGesture()
                                    .onChanged { value in
                                        draggableTag.scale = value
                                    }
                                    .onEnded { _ in
                                        draggableTag.lastScaleValue *= draggableTag.scale
                                        draggableTag.scale = 1.0
                                        updateTagState(geo: geometry)
                                    }
                                )
                            )
                            .onTapGesture {
                                tapCount += 1
                                updateTagAppearance()
                            }
                        }
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        let scale = draggableTag.lastScaleValue * draggableTag.scale
                                        let globalFrame = geo.frame(in: .global)
                                        
                                        draggableTag.position = CGSize(
                                            width: -geo.size.width / 2 + globalFrame.width * scale / 2,
                                            height: -geo.size.height / 2 + globalFrame.height * scale / 2
                                        )
                                        
                                        draggableTag.globalFrame = CGRect(
                                            origin: globalFrame.origin,
                                            size: CGSize(width: globalFrame.width * scale, height: globalFrame.height * scale)
                                        )
                                        
                                        updateTagState(geo: geo)
                                    }
                            }
                        )
                    }
                }
            }
        }
    }

    private func updateTagAppearance() {
        switch tapCount {
        case 1:
            draggableTag = draggableTag.copyWith(newBackground: .white, newTextColor: .black)
        case 2:
            draggableTag = draggableTag.copyWith(newBackground: .white, newTextColor: .purple)
        case 3:
            draggableTag = draggableTag.copyWith(useGradientText: true)
        case 4:
            draggableTag = draggableTag.copyWith(newBackground: .white, newTextColor: .black, useGradientText: false)
            draggableTag.text = draggableTag.text.uppercased()
        case 5:
            draggableTag = draggableTag.copyWith(newBackground: .white, newTextColor: .purple, useGradientText: false)
            draggableTag.text = draggableTag.text.uppercased()
        default:
            draggableTag = draggableTag.copyWith(newBackground: .black, newTextColor: .white, useGradientText: false)
            draggableTag.text = draggableTag.originalText

            tapCount = 0
        }
    }

    private func updateTagState(geo: GeometryProxy) {
        let scale = draggableTag.lastScaleValue * draggableTag.scale
        
        let transformedSize = CGSize(width: geo.size.width * scale, height: geo.size.height * scale)
        
        let offsetX = (geo.size.width * scale - geo.size.width) / 2
        let offsetY = (geo.size.height * scale - geo.size.height) / 2
        
        draggableTag.globalFrame = CGRect(
            origin: CGPoint(
                x: geo.frame(in: .global).origin.x + dragOffset.width + draggableTag.position.width - offsetX,
                y: geo.frame(in: .global).origin.y + dragOffset.height + draggableTag.position.height - offsetY
            ),
            size: transformedSize
        )
        print("Updated Location Global Frame: \(draggableTag.globalFrame)")
    }
}

extension DraggableTag {
    func copyWith(newBackground: Color? = nil, newTextColor: Color? = nil, useGradientText: Bool? = nil) -> DraggableTag {
        var copy = self
        if let newBackground = newBackground {
            copy.backgroundColor = newBackground
        }
        if let newTextColor = newTextColor {
            copy.textColor = newTextColor
        }
        if let useGradientText = useGradientText {
            copy.useGradientText = useGradientText
        }
        return copy
    }
}



//
//  DraggableTag.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 11.09.2024.
//

import SwiftUI

struct DraggableTag: Identifiable, Equatable {
    var id = UUID()
    var text: String
    var position: CGSize
    var scale: CGFloat
    var angle: Angle
    var lastScaleValue: CGFloat = 1.0
    var zIndex: CGFloat
    var globalFrame: CGRect = .zero
    var backgroundColor: Color
    var textColor: Color
    var useGradientText: Bool = false
    var originalText: String
}

struct DraggableTagView: View {
    @Binding var draggableTag: DraggableTag
    @Binding var hideButtons: Bool
    @Binding var selectedTagIndex: Int?
    
    @State private var isDraggingOverDelete: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var shouldRemove: Bool = false
    @State private var tapCount: Int = 0
    @State private var currentAngle: Angle = .zero
    
    
    
    
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
                            
                            Text(draggableTag.text)
                                .font(Font.system(size: 26))
                                .foregroundColor(draggableTag.useGradientText ? .clear : draggableTag.textColor)
                                .overlay(
                                    draggableTag.useGradientText ?
                                    gradientColor.mask(Text(draggableTag.text).font(.system(size: 26))) : nil
                                )
                                .padding(6)
                                .background(draggableTag.backgroundColor.opacity(0.6))
                                .cornerRadius(5)
                                .scaleEffect(draggableTag.lastScaleValue * draggableTag.scale)
                                .rotationEffect(draggableTag.angle)
                                .offset(x: draggableTag.position.width + dragOffset.width,
                                        y: draggableTag.position.height + dragOffset.height)
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
                                                        
                                                        draggableTag = DraggableTag(
                                                            text: "",
                                                            position: .zero,
                                                            scale: 1.0,
                                                            angle: .zero,
                                                            zIndex: 1,
                                                            backgroundColor: .clear,
                                                            textColor: .clear,
                                                            originalText: ""
                                                            
                                                        )
                                                    }
                                                    
                                                } else {
                                                    draggableTag.position.width += dragOffset.width
                                                    draggableTag.position.height += dragOffset.height
                                                    updateTagState(geo: geometry)
                                                }
                                                dragOffset = .zero
                                                hideButtons = false
                                                isDraggingOverDelete = false
                                            },
                                        RotationGesture()
                                            .onChanged { newAngle in
                                                draggableTag.angle = currentAngle + newAngle
                                            }
                                            .onEnded { newAngle in
                                                currentAngle += newAngle
                                                updateTagState(geo: geometry)
                                                if hideButtons == true {
                                                    hideButtons = false
                                                }
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
        print("Updated Tag Global Frame: \(draggableTag.globalFrame)")
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

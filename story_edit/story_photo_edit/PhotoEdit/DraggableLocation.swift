import SwiftUI
import UIKit

struct DraggableLocation: Identifiable, Equatable {
    var id = UUID()
    var position: CGSize
    var scale: CGFloat
    var angle: Angle
    var lastScaleValue: CGFloat = 1.0
    var zIndex: CGFloat
    var globalFrame: CGRect = .zero
    var locationText: String
    var backgroundColor: Color
    var textColor: Color
}

struct DraggableLocationView: View {
    @Binding var draggableLocation: DraggableLocation
    @Binding var selectedLocationIndex: Int?
    var index: Int
    @Binding var hideButtons: Bool
    @State private var tapCount: Int = 0
    
    @State private var isDraggingOverDelete: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var shouldRemove: Bool = false
    @State private var currentAngle: Angle = .zero

    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    if !shouldRemove {
                        ZStack {
                            HStack {
                                Text("" + draggableLocation.locationText)
                                    .font(Font.system(size: 24))
                                    .foregroundColor(draggableLocation.textColor)
                            }
                            
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(draggableLocation.backgroundColor.opacity(0.6))
                            .cornerRadius(5)
                            .scaleEffect(draggableLocation.lastScaleValue * draggableLocation.scale)
                            .rotationEffect(draggableLocation.angle)
                            .position(x: geometry.size.width / 2 + draggableLocation.position.width + dragOffset.width,
                                      y: geometry.size.height / 2 + draggableLocation.position.height + dragOffset.height)
                        }
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        updateLocationState(geo: geo)
                                        
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
                                        if deleteAreaFrame.contains(
                                            CGPoint(x: value.location.x + geometry.frame(in: .global).minX,
                                                    y: value.location.y + geometry.frame(in: .global).minY)) {
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
                                                if let selectedIndex = selectedLocationIndex {
                                                    draggableLocation = DraggableLocation(
                                                        position: draggableLocation.position,
                                                        scale: 1.0,
                                                        angle: .zero,
                                                        zIndex: CGFloat(selectedIndex),
                                                        locationText: "",
                                                        backgroundColor: .clear,
                                                        textColor: .clear
                                                        
                                                    )
                                                }
                                            }
                                        } else {
                                            draggableLocation.position.width += dragOffset.width
                                            draggableLocation.position.height += dragOffset.height
                                            dragOffset = .zero
                                            updateLocationState(geo: geometry)
                                        }
                                        dragOffset = .zero
                                        hideButtons = false
                                        isDraggingOverDelete = false
                                    },
                                RotationGesture()
                                    .onChanged { newAngle in
                                        draggableLocation.angle  = currentAngle + newAngle
                                    }
                                    .onEnded { newAngle in
                                        currentAngle += newAngle
                                        updateLocationState(geo: geometry)
                                        if hideButtons == true {
                                            hideButtons = false
                                        }
                                    }
                            )
                            .simultaneously(with: MagnificationGesture()
                                .onChanged { value in
                                    draggableLocation.scale = value
                                }
                                .onEnded { _ in
                                    draggableLocation.lastScaleValue *= draggableLocation.scale
                                    draggableLocation.scale = 1.0
                                    updateLocationState(geo: geometry)
                                }
                            )
                        )
                        .onTapGesture {
                            tapCount += 1
                            updateLocationOnTap()
                            
                        }
                    }
                }
            }
        }
    }
    
    private func updateLocationState(geo: GeometryProxy) {
        let scale = draggableLocation.lastScaleValue * draggableLocation.scale
        let transformedSize = CGSize(width: geo.size.width * scale, height: geo.size.height * scale)
        let offsetX = (geo.size.width * scale - geo.size.width) / 2
        let offsetY = (geo.size.height * scale - geo.size.height) / 2
        draggableLocation.globalFrame = CGRect(
            origin: CGPoint(
                x: geo.frame(in: .global).origin.x + dragOffset.width + draggableLocation.position.width - offsetX,
                y: geo.frame(in: .global).origin.y + dragOffset.height + draggableLocation.position.height - offsetY
            ),
            size: transformedSize
        )
        print("Updated Location Global Frame: \(draggableLocation.globalFrame)", transformedSize)
    }
    
    
    private func updateLocationOnTap() {
        switch tapCount {
        case 1:
            draggableLocation.textColor = .black
            draggableLocation.backgroundColor = .white
            draggableLocation.locationText = draggableLocation.locationText.prefix(1).uppercased() + draggableLocation.locationText.dropFirst().lowercased()
            draggableLocation = draggableLocation.copyWith(newBackground: .white, newTextColor: .black)
            
        case 2:
            draggableLocation.textColor = .red
            draggableLocation.backgroundColor = .white
            draggableLocation = draggableLocation.copyWith(newBackground: .white, newTextColor: .red)
            
        default:
            draggableLocation.locationText = "📍Test City"
            draggableLocation.textColor = .white
            draggableLocation.backgroundColor = .black
            draggableLocation = draggableLocation.copyWith(newBackground: .black, newTextColor: .white)
            tapCount = 0
        }
    }
}



extension DraggableLocation {
    func copyWith(newBackground: Color? = nil, newTextColor: Color?) -> DraggableLocation {
        var copy = self
        if let newBackground = newBackground {
            copy.backgroundColor = newBackground
        }
        if let newTextColor = newTextColor {
            copy.textColor = newTextColor
        }
        return copy
    }
}

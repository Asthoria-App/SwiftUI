import SwiftUI
import UIKit

struct DraggableLocation {
    var image: UIImage = UIImage()
    var position: CGSize
    var scale: CGFloat
    var angle: Angle
    var lastScaleValue: CGFloat = 1.0
    var zIndex: CGFloat
    var globalFrame: CGRect = .zero
    var locationText: String = "Test City"
    var backgroundColor: Color = .black
    var textColor: Color = .white
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
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    if !shouldRemove {
                        ZStack {
                            HStack {
                                Text("📍 " + draggableLocation.locationText)
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
                                        draggableLocation.image = getViewAsImage()
                                        
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
                                                    draggableLocation = DraggableLocation(image: UIImage(), position: draggableLocation.position, scale: 1.0, angle: .zero, zIndex: CGFloat(selectedIndex))
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
                                        draggableLocation.angle += newAngle - draggableLocation.angle
                                    }
                                    .onEnded { newAngle in
                                        draggableLocation.angle = newAngle
                                        updateLocationState(geo: geometry)
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
                            print("Tap count: \(tapCount)")
                            print("Before generating image - locationText: \(draggableLocation.locationText), textColor: \(draggableLocation.textColor), backgroundColor: \(draggableLocation.backgroundColor)")
                            
                            updateLocationOnTap()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                draggableLocation.image = getViewAsImage()
                                
                                print("After generating image - locationText: \(draggableLocation.locationText), textColor: \(draggableLocation.textColor), backgroundColor: \(draggableLocation.backgroundColor)")
                            }
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
    
    private func getViewAsImage() -> UIImage {
        let label = UILabel()
        label.text = "📍 " + draggableLocation.locationText
        
        
        label.font = UIFont.systemFont(ofSize: 24)
        
        
        let uiColor = convertColorToUIColor(color: draggableLocation.textColor)
        let backgroundColor = convertColorToUIColor(color: draggableLocation.backgroundColor)
        
        label.textColor = uiColor
        label.backgroundColor = backgroundColor.withAlphaComponent(0.6)
        
        print("Generating Image with text: \(draggableLocation.locationText)")
        print("Generating Image with textColor: \(draggableLocation.textColor)")
        print("Generating Image with backgroundColor: \(draggableLocation.backgroundColor)")
        
        label.textAlignment = .center
        label.sizeToFit()
        label.frame = CGRect(x: 0, y: 0, width: 140, height: 40)
        
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
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
            draggableLocation.locationText = "Test City"
            draggableLocation.textColor = .white
            draggableLocation.backgroundColor = .black
            draggableLocation = draggableLocation.copyWith(newBackground: .black, newTextColor: .white)
            tapCount = 0
        }
    }
}

func convertColorToUIColor(color: Color) -> UIColor {
    if let cgColor = color.cgColor {
        return UIColor(cgColor: cgColor)
    } else {
        return UIColor.systemRed
    }
}

extension DraggableLocation {
    func copyWith(newBackground: Color? = nil, newTextColor: Color?) -> DraggableLocation {
        var copy = self
        if let newBackground = newBackground {
            print(newBackground.description, "newBackground")
            copy.backgroundColor = newBackground
        }
        if let newTextColor = newTextColor {
            copy.textColor = newTextColor
            print(newTextColor.description, "newTextColor")
        }
        return copy
    }
}

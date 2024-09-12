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
    var currentTimeStyle: TimeStyle = .normal
}

enum TimeStyle {
    case normal
    case analogClock
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
                        Image(uiImage: getTimeImage(for: draggableTime.currentTimeStyle))
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: 150,
                                height: draggableTime.currentTimeStyle == .normal ? 80 : 150
                            )
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
                                            updateTimeState(geo: geo)
                                        }
                                }
                            )
                            .gesture(
                                SimultaneousGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            hideButtons = true
                                            dragOffset = value.translation
                                            
                                            let deleteAreaFrame = CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height - 100, width: 150, height: 150)
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
                          
                                switch draggableTime.currentTimeStyle {
                                case .normal:
                                    draggableTime.currentTimeStyle = .analogClock
                                    draggableTime.image = getAnalogClockImage()
                                    
                                case .analogClock:
                                    draggableTime.currentTimeStyle = .normal
                                    draggableTime.image = getCurrentTimeAsImage()
                                }
                            }
                    }
                }
            }
        }
    }
    
    private func getTimeImage(for style: TimeStyle) -> UIImage {
        switch style {
        case .normal:
            return getCurrentTimeAsImage()
        case .analogClock:
            return getAnalogClockImage()
        }
    }

    private func updateTimeState(geo: GeometryProxy) {
        let scale = draggableTime.lastScaleValue * draggableTime.scale
        let transformedSize = CGSize(width: geo.size.width * scale, height: geo.size.height * scale)
        let offsetX = (geo.size.width * scale - geo.size.width) / 2
        let offsetY = (geo.size.height * scale - geo.size.height) / 2
        draggableTime.globalFrame = CGRect(
            origin: CGPoint(
                x: geo.frame(in: .global).origin.x + dragOffset.width + draggableTime.position.width - offsetX,
                y: geo.frame(in: .global).origin.y + dragOffset.height + draggableTime.position.height - offsetY
            ),
            size: transformedSize
        )
    }
}
func getCurrentTimeAsImage() -> UIImage {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    let currentTimeString = dateFormatter.string(from: Date())
    
    let label = UILabel()
    label.text = currentTimeString
    label.font = UIFont.systemFont(ofSize: 50)
    label.textColor = .white
    label.textAlignment = .center
    label.sizeToFit()
    label.frame = CGRect(x: 0, y: 0, width: label.frame.width + 20, height: label.frame.height + 10)
    label.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
    label.layer.shadowOpacity = 0.7
    label.layer.shadowOffset = CGSize(width: 3, height: 3)
    label.layer.shadowRadius = 5
    label.layer.masksToBounds = false
    
    UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
    label.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image ?? UIImage()
}
func getAnalogClockImage() -> UIImage {
    let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
    
    let clockFace = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
    clockFace.layer.cornerRadius = 75
    clockFace.layer.borderWidth = 4
    clockFace.layer.borderColor = UIColor.black.cgColor
    containerView.addSubview(clockFace)
    
    let date = Date()
    let calendar = Calendar.current
    let hour = CGFloat(calendar.component(.hour, from: date) % 12)
    let minute = CGFloat(calendar.component(.minute, from: date))
    
    let hourHand = UIView(frame: CGRect(x: 75, y: 75, width: 4, height: 40))
    hourHand.backgroundColor = .black
    hourHand.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
    hourHand.transform = CGAffineTransform(rotationAngle: (hour / 12.0) * .pi * 2)
    containerView.addSubview(hourHand)
    
    let minuteHand = UIView(frame: CGRect(x: 75, y: 75, width: 3, height: 60))
    minuteHand.backgroundColor = .black
    minuteHand.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
    minuteHand.transform = CGAffineTransform(rotationAngle: (minute / 60.0) * .pi * 2)
    containerView.addSubview(minuteHand)
    
    UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, false, 0)
    containerView.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image ?? UIImage()
}

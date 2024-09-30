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
    @State private var currentAngle: Angle = .zero

    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    if !shouldRemove {
                        Image(uiImage: getTimeImage(for: draggableTime.currentTimeStyle))
                            .resizable()
                            .scaledToFill()
                            .opacity(draggableTime.image.size == .zero ? 0 : 1)
                            .frame(
                                width: 160,
                                height: draggableTime.currentTimeStyle == .normal ? 80 : 160
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
                                            draggableTime.image = getCurrentTimeAsImage()
                                        }
                                }
                            )
                            .gesture(
                                SimultaneousGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            hideButtons = true
                                            dragOffset = value.translation
                                            
                                            let deleteAreaFrame = CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height - 100, width: 160, height: 160)
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
                                                updateTimeState(geo: geometry)
                                            }
                                            dragOffset = .zero
                                            hideButtons = false
                                            isDraggingOverDelete = false
                                        },
                                    RotationGesture()
                                        .onChanged { newAngle in
                                            draggableTime.angle = currentAngle + newAngle
                                        }
                                        .onEnded { newAngle in
                                            currentAngle += newAngle
                                            updateTimeState(geo: geometry)
                                            if hideButtons == true {
                                                hideButtons = false
                                            }
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
    let clockSize = CGSize(width: 160, height: 160)
    let renderer = UIGraphicsImageRenderer(size: clockSize)
    
    let image = renderer.image { context in
        let center = CGPoint(x: clockSize.width / 2, y: clockSize.height / 2)
        let radius: CGFloat = 75
        let clockFaceBounds = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        
        context.cgContext.setLineWidth(4)
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.addEllipse(in: clockFaceBounds)
        context.cgContext.strokePath()
        
        let numberFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: numberFont,
            .foregroundColor: UIColor.black
        ]
        
        for hour in 1...12 {
            let angle = CGFloat(hour) / 12.0 * .pi * 2 - .pi / 2
            let numberString = "\(hour)" as NSString
            let numberSize = numberString.size(withAttributes: numberAttributes)
            
            let numberPosition = CGPoint(
                x: center.x + cos(angle) * (radius * 0.85) - numberSize.width / 2,
                y: center.y + sin(angle) * (radius * 0.85) - numberSize.height / 2
            )
            
            numberString.draw(at: numberPosition, withAttributes: numberAttributes)
        }
        
        let date = Date()
        let calendar = Calendar.current
        let hour = CGFloat(calendar.component(.hour, from: date) % 12)
        let minute = CGFloat(calendar.component(.minute, from: date))
        let second = CGFloat(calendar.component(.second, from: date))
        
        context.cgContext.setLineWidth(4)
        let hourAngle = ((hour / 12.0) + (minute / 60.0 / 12.0)) * .pi * 2 - .pi / 2
        context.cgContext.move(to: center)
        context.cgContext.addLine(to: CGPoint(
            x: center.x + cos(hourAngle) * (radius * 0.5),
            y: center.y + sin(hourAngle) * (radius * 0.5)
        ))
        context.cgContext.strokePath()
        
        context.cgContext.setLineWidth(3)
        let minuteAngle = (minute / 60.0) * .pi * 2 - .pi / 2
        context.cgContext.move(to: center)
        context.cgContext.addLine(to: CGPoint(
            x: center.x + cos(minuteAngle) * (radius * 0.7),
            y: center.y + sin(minuteAngle) * (radius * 0.7)
        ))
        context.cgContext.strokePath()
        
     
        
        context.cgContext.setFillColor(UIColor.black.cgColor)
        context.cgContext.addArc(center: center, radius: 4, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        context.cgContext.fillPath()
    }
    
    return image
}

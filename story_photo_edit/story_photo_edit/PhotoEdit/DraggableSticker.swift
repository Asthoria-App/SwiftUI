//
//  DraggableSticker.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 29.08.2024.
//

import SwiftUI

struct DraggableSticker {
    var image: UIImage
    var position: CGSize
    var scale: CGFloat
    var angle: Angle
    var zIndex: CGFloat
    var globalFrame: CGRect = .zero
}

struct DraggableStickerView: View {
    @Binding var draggableSticker: DraggableSticker
    @Binding var hideButtons: Bool
    let deleteArea: CGRect
    var onDelete: () -> Void
    
    @State private var isDraggingOverDelete: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var shouldRemove: Bool = false
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var currentAngle: Angle = .zero
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    if !shouldRemove {
                        Image(uiImage: draggableSticker.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .scaleEffect(lastScaleValue * draggableSticker.scale)
                            .rotationEffect(draggableSticker.angle + currentAngle)
                            .position(x: geometry.size.width / 2 + draggableSticker.position.width + dragOffset.width,
                                      y: geometry.size.height / 2 + draggableSticker.position.height + dragOffset.height)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            updateStickerState(geo: geo)
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
                                                    onDelete()
                                                }
                                            } else {
                                                draggableSticker.position.width += dragOffset.width
                                                draggableSticker.position.height += dragOffset.height
                                                dragOffset = .zero
                                                updateStickerState(geo: geometry)
                                            }
                                            dragOffset = .zero
                                            hideButtons = false
                                            isDraggingOverDelete = false
                                        },
                                    RotationGesture()
                                        .onChanged { newAngle in
                                            currentAngle = newAngle
                                        }
                                        .onEnded { newAngle in
                                            draggableSticker.angle += currentAngle
                                            currentAngle = .zero
                                            updateStickerState(geo: geometry)
                                        }
                                )
                                .simultaneously(with: MagnificationGesture()
                                    .onChanged { value in
                                        draggableSticker.scale = value
                                    }
                                    .onEnded { _ in
                                        lastScaleValue *= draggableSticker.scale
                                        draggableSticker.scale = 1.0
                                        updateStickerState(geo: geometry)
                                    }
                                )
                            )
                    }
                }
                .onAppear {
                    print("Sticker's Geometry Size: \(geometry.size)")
                    print("Sticker's Initial Global Frame: \(geometry.frame(in: .global))")
                }
            }
        }
    }
    
    private func updateStickerState(geo: GeometryProxy) {
        let scale = lastScaleValue * draggableSticker.scale
        
        let transformedSize = CGSize(width: geo.size.width * scale, height: geo.size.height * scale)
        
        let offsetX = (geo.size.width * scale - geo.size.width) / 2
        let offsetY = (geo.size.height * scale - geo.size.height) / 2

        draggableSticker.globalFrame = CGRect(
            origin: CGPoint(
                x: geo.frame(in: .global).origin.x + dragOffset.width + draggableSticker.position.width - offsetX,
                y: geo.frame(in: .global).origin.y + dragOffset.height + draggableSticker.position.height - offsetY
            ),
            size: transformedSize
        )
        
        print("Updated Sticker Global Frame: \(draggableSticker.globalFrame)")
    }


}

import Combine

struct BottomSheetStickerPickerView: View {
    @Binding var selectedStickerImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    let stickers: [String] = ["1", "2", "3", "4", "5", "7", "8", "1", "4", "2", "4", "3"]
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    @State private var searchText: String = ""
    @State private var filteredStickers: [String] = []
    @State private var searchCancellable: AnyCancellable?
    
    var body: some View {
        ZStack {
            VStack {
                Text("Select a Sticker")
                    .font(.headline)
                    .padding()
                
                TextField("Search stickers", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchText) { newValue in
                        filterStickers(with: newValue)
                    }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        if filteredStickers.isEmpty {
                            Text("No stickers found")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(filteredStickers.indices, id: \.self) { index in
                                let stickerName = filteredStickers[index]
                                
                                if let stickerImage = UIImage(named: stickerName) {
                                    Image(uiImage: stickerImage)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .background(Color.clear)
                                        .onTapGesture {
                                            selectedStickerImage = stickerImage
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .padding()
            .background(Color.black)
            .cornerRadius(10)
            .shadow(radius: 5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .onAppear {
                filterStickers(with: searchText)
            }
        }
    }
    
    private func filterStickers(with text: String) {
        if text.isEmpty {
            filteredStickers = stickers
        } else {
            filteredStickers = stickers.filter { $0.contains(text) }
        }
    }
}

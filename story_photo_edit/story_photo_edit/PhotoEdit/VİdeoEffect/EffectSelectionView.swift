//
//  EffectSelectionView.swift
//  story_photo_edit
//
//  Created by Aysema ÇAm on 19.09.2024.
//

import SwiftUI


struct EffectSelectionView: View {
    @Binding var selectedEffect: EffectType?
    let effects: [EffectType] = [.color(.red), .color(.blue), .color(.purple), .color(.brown), .color(.cyan), .monochrome]
    
    @State private var currentIndex: Int = 0
    @State private var scrollOffset: CGFloat = 0.0
    @State private var dragOffset: CGFloat = 0.0
    
    let buttonWidth: CGFloat = 86
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollViewReader { scrollViewProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 30) {
                            ForEach(effects.indices, id: \.self) { index in
                                VStack {
                                    EffectButton(effectType: effects[index], selectedEffect: $selectedEffect)
                                        .frame(width: 56, height: 56)
                                        .padding(.top, 10)
                                    
                                    Text(effects[index].name)
                                        .font(.caption)
                                        .foregroundColor(selectedEffect == effects[index] ? Color.blue : Color.white)
                                        .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 1)
                                    
                                }
                            }
                        }
                        .padding(.horizontal, (geometry.size.width - buttonWidth) / 2)
                        .offset(x: scrollOffset + dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation.width
                                }
                                .onEnded { value in
                                    dragOffset = 0
                                    let totalOffset = scrollOffset + value.translation.width
                                    let snapIndex = Int(round(totalOffset / buttonWidth))
                                    let nearestIndex = min(max(currentIndex - snapIndex, 0), effects.count - 1)
                                    currentIndex = nearestIndex
                                    withAnimation(.easeOut) {
                                        scrollOffset = -CGFloat(currentIndex) * 56
                                    }
                                }
                        )
                    }
                    
                    .onAppear {
                        withAnimation(.easeOut) {
                            scrollOffset = -CGFloat(currentIndex) * buttonWidth
                        }
                    }
                }
            }
            .frame(height: 190)
            
            
        }
        .background(Color.black.opacity(0.3))
    }
}

enum EffectType: Hashable, Equatable {
    case color(Color)
    case monochrome
    
    var description: String {
        switch self {
        case .color(let color):
            return "Color: \(color.description.capitalized)"
        case .monochrome:
            return "Monochrome"
        }
    }
    
    var name: String {
        switch self {
        case .color(.red): return "Red"
        case .color(.blue): return "Blue"
        case .color(.purple): return "Purple"
        case .color(.brown): return "Brown"
        case .color(.cyan): return "Cyan"
        case .monochrome: return "Monochrome"
        default: return "None"
        }
    }
}

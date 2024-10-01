//
//  EffectButton.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 19.09.2024.
//

import SwiftUI

struct EffectButton: View {
    var effectType: EffectType
    @Binding var selectedEffect: EffectType?
    
    var body: some View {
        Button(action: {
            selectedEffect = effectType
        }) {
            ZStack {
                Image(imageName(for: effectType))
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                
                Circle()
                    .stroke(selectedEffect == effectType ? Color.blue : Color.white, lineWidth: 2)
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 3, y: 3)
            }
            .frame(width: 56, height: 56)
        }
    }
    
    private func imageName(for effect: EffectType) -> String {
        switch effect {
        case .color(.red): return "view"
        case .color(.blue): return "view2"
        case .color(.purple): return "view3"
        case .color(.brown): return "view4"
        case .color(.cyan): return "view"
        default: return "view2"
        }
    }
}


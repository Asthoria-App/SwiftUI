//
//  BottomSheetBlurView.swift
//  BottomSheetModifier
//
//  Created by Aysema Çam on 26.09.2024.
//

import SwiftUI

struct BottomSheetBlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

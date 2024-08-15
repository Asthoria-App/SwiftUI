//
//  LottieView.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 8.08.2024.
//

import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    var filename: String
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named(filename)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop 
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        uiView.play()
    }
}
